#include <string>
#include <boost/program_options.hpp>


namespace po = boost::program_options;

po::variables_map parseOptions(int argc, char *argv[]);
std::string getHelp(po::options_description desc);
