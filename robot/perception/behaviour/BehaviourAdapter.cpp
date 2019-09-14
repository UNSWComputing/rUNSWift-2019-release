#include <Python.h>

#include <fstream>
#include <limits>
#include <utility>
#include <vector>
#include <sstream>
#include <string>
#include <cmath>
#include "perception/behaviour/BehaviourAdapter.hpp"
#include "perception/behaviour/BehaviourHelpers.hpp"

#include "blackboard/Blackboard.hpp"
#include "utils/Logger.hpp"
#include "types/BehaviourRequest.hpp"
#include "utils/body.hpp"
#include "utils/speech.hpp"
#include "utils/basic_maths.hpp"
#include "types/SensorValues.hpp"
#include "perception/behaviour/python/PythonSkill.hpp"
#include "utils/OptionConstants.hpp"

#include <boost/python.hpp>

static const int REMOTE_TIMEOUT = 2; // timout for remote control in seconds (will stop the robot if message older than this)

using namespace std;
using namespace boost::python;

BehaviourAdapter::BehaviourAdapter(Blackboard *bb) : Adapter(bb), calibrationSkill(bb),
         safetySkill(bb->behaviour.useGetups)
{
   llog(INFO) << "Constructing BehaviourAdapter" << endl;
   //Read options from black board
   readOptions(bb->config);

   std::string hostname;
   ifstream hostfile ("/etc/hostname");
   getline (hostfile, hostname);
   pythonSkill = new PythonSkill(bb);

   // Alert runswift team - whistle detection requires 4 channels, not 2
   std::string noHearWhistles = "";
   int ret = system("python $HOME/whistle/alert_pulseaudio.py");
   if (ret != 0) {
      noHearWhistles += "I can not hear whistles. ";
      std::cout << noHearWhistles << std::endl;
   }

   // Max string length is 70 characters as defined by MAX_SAY_LENGTH in robot/libagent/AgentData.hpp
   std::stringstream startupSpeech;
   startupSpeech << noHearWhistles << std::string("Player ") << BehaviourHelpers::playerNumber(blackboard);
   if (ret != 0) {
     startupSpeech << " ... " << hostname;
   } else {
      if (BehaviourHelpers::teamNumber(blackboard) == 18) {
          startupSpeech << " team rUNSWift";
      }
      else {
          startupSpeech << " team " << BehaviourHelpers::teamNumber(blackboard);
      }
      if (hostname == "mario") {
            startupSpeech << " ... It's a me ... " << hostname << " ... wah who! ...";
      }
      else {
            startupSpeech << " ... I am ... " << hostname;
      }
   }
   std::cout << startupSpeech.str() << std::endl;
   SAY(startupSpeech.str());
}

BehaviourAdapter::~BehaviourAdapter() {
}

void BehaviourAdapter::readOptions(const boost::program_options::variables_map& config) {
   remoteControlActive = config["debug.remotecontrol"].as<bool>();
   if (remoteControlActive) {
         llog(INFO) << "BehaviourAdapter using remote control";
   }
   runningIMUCalibrationSkill = config["calibration.imu"].as<bool>();
   if (runningIMUCalibrationSkill) {
      llog(INFO) << "BehaviourAdapter using imu calibration skill";
   }
   runningKickCalibrationSkill = config[CALIBRATION_KICK].as<bool>();
   if (runningKickCalibrationSkill) {
      llog(INFO) << "BehaviourAdapter using kick calibration skill";
      std::string footString = config["kick.foot"].as<std::string>();
      if(footString == "RIGHT")
         kickCalibrationFoot = ActionCommand::Body::RIGHT;
      else {
         if (footString != "LEFT")
            llog(INFO) << "Could not parse foot argument. Setting to left" << std::endl;
         kickCalibrationFoot = ActionCommand::Body::LEFT;
      }

   }
   // for Log.py
   setenv("LOG_PATH", config["debug.logpath"].as<string>().c_str(), 1);
   // so we don't have to worry about old .pyc files
   setenv("PYTHONDONTWRITEBYTECODE", "1", 1);
   safetySkill.readOptions(config);
}

void BehaviourAdapter::tick() {
   BehaviourRequest behaviourRequest;
   if (readFrom(kinematics, isCalibrating)) {
      // kinematics calibrator
      behaviourRequest = calibrationSkill.execute();
   } else if (remoteControlActive) {
      //check the request is sufficiently recent
      time_t reqTime = readFrom(remoteControl, time_received);
      time_t currTime;
      time(&currTime);
      // Get the motion request from remote control
      if (currTime - reqTime < REMOTE_TIMEOUT) {
          behaviourRequest = readFrom(remoteControl, request);
      } else {
            //Set the action to be standing still (all velocities 0)
            //Set bend to 0 to straighten legs
            behaviourRequest.actions.body = ActionCommand::Body(ActionCommand::Body::WALK, 0, 0, 0, 0.1, 0);
      }
   } else if (runningIMUCalibrationSkill) {
      behaviourRequest = imuCalibrationSkill.execute(readFrom(motion, sensors));
   } else if (runningKickCalibrationSkill) {
      behaviourRequest = kickCalibrationSkill.execute(readFrom(stateEstimation, ballPosRRC), readFrom(vision, balls),
                                                      kickCalibrationFoot);
   } else {
     // Run the python skill
      behaviourRequest = pythonSkill->execute();
   }

   int playerNumber = readFrom(gameController, player_number);
   TeamInfo teamInfo = readFrom(gameController, our_team);
   bool isPenalised = teamInfo.players[playerNumber - 1].penalty != PENALTY_NONE;
   RoboCupGameControlData gameControllerData = readFrom(gameController, data);
   bool isMotionAllowed = gameControllerData.state == STATE_PLAYING || gameControllerData.state == STATE_READY;
   bool ukemiEnabled = isMotionAllowed && !isPenalised;

   // Write ActionCommands to blackboard
   int writeBuf = (readFrom(behaviour, readBuf) + 1) % 2;
   writeTo(behaviour, request[writeBuf], safetySkill.wrapRequest(behaviourRequest, readFrom(motion, sensors), ukemiEnabled));
   writeTo(behaviour, readBuf, writeBuf);

   // Write behaviourSharedData to blackboard, to broadcast to the team
   writeTo(behaviour, behaviourSharedData, behaviourRequest.behaviourSharedData);
}
