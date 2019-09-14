#pragma once

/** The field coordinate system in mm and radians (rad)
 *  X -- is along the length of the field, +ve towards opponent's goal
 *  Y -- is along the width of the field, +ve towards the left hand side
 *  0 rad -- facing straight towards opponent's goal at origin
 *  radians are calculated counter clock-wise
 *  NOTE: we use -PI, not PI for 180 degrees
 *  NOTE: unless explicitly specified all dimensions includes line width
 */

#define FIELD_LINE_WIDTH 50
//#define USING_SMALL_FIELD


// Will need to re-measure field when it is built
#ifndef USING_SMALL_FIELD
   #define ROBOTS_PER_TEAM 6

   /** Field line dimensions */
   #define FIELD_LENGTH 9010
   #define FIELD_WIDTH 6020

   #define FIELD_LENGTH_OFFSET 700
   #define FIELD_WIDTH_OFFSET 700

   #define OFFNAO_FIELD_LENGTH_OFFSET 730
   #define OFFNAO_FIELD_WIDTH_OFFSET 730

   /** Goal box */
   #define GOAL_BOX_LENGTH 615
   #define GOAL_BOX_WIDTH 2220

   /** Penalty Cross */
   #define PENALTY_CROSS_DIMENSIONS 100 /* i.e. dimensions of square fitted around it */
   #define DIST_GOAL_LINE_TO_PENALTY_CROSS 1290 /* to middle of closest penalty cross */
   #define PENALTY_CROSS_ABS_X (FIELD_LENGTH / 2 - DIST_GOAL_LINE_TO_PENALTY_CROSS)

   /** Center Circle */
   #define CENTER_CIRCLE_DIAMETER 1500

   /** Goal Posts */
   #define GOAL_POST_DIAMETER 90
   #define GOAL_BAR_DIAMETER 100  // Double check this once field is built
   #define GOAL_POST_HEIGHT 800 // Measured from the bottom of the crossbar to the ground

   #define GOAL_SUPPORT_DIAMETER 46
   #define GOAL_WIDTH 1565 /* top view end-to-end from middle of goal posts */
   #define GOAL_DEPTH 450 /* Measured from the front edge of the crossbar to the centre of the rear bar */

   //////////////////////////////////////////////////////////////

   // May need to define white support bar dimensions for field lines

#else
     #define ROBOTS_PER_TEAM 6

   /** Field line dimensions */
   #define FIELD_LENGTH 4240
   #define FIELD_WIDTH 2350

   #define FIELD_LENGTH_OFFSET 130
   #define FIELD_WIDTH_OFFSET 130

   #define OFFNAO_FIELD_LENGTH_OFFSET 130
   #define OFFNAO_FIELD_WIDTH_OFFSET 130

   /** Goal box */
   #define GOAL_BOX_LENGTH 420
   #define GOAL_BOX_WIDTH 1300

   /** Penalty Cross */
   #define PENALTY_CROSS_DIMENSIONS 100 /* i.e. dimensions of square fitted around it */
   #define DIST_GOAL_LINE_TO_PENALTY_CROSS 1300 /* to middle of closest penalty cross */
   #define PENALTY_CROSS_ABS_X (FIELD_LENGTH / 2 - DIST_GOAL_LINE_TO_PENALTY_CROSS)

   /** Center Circle */
   #define CENTER_CIRCLE_DIAMETER 780

   /** Goal Posts */
   #define GOAL_POST_DIAMETER 40
   #define GOAL_BAR_DIAMETER 100  // Double check this once field is built
   #define GOAL_POST_HEIGHT 800 // Measured from the bottom of the crossbar to the ground

   #define GOAL_SUPPORT_DIAMETER 46
   #define GOAL_WIDTH 1600 /* top view end-to-end from middle of goal posts */
   #define GOAL_DEPTH 500 /* Measured from the front edge of the crossbar to the centre of the rear bar */
#endif

/** Field dimensions including edge offsets */
#define FULL_FIELD_LENGTH (FIELD_LENGTH + (FIELD_LENGTH_OFFSET * 2))
#define OFFNAO_FULL_FIELD_LENGTH (FIELD_LENGTH + (OFFNAO_FIELD_LENGTH_OFFSET * 2))
#define FULL_FIELD_WIDTH (FIELD_WIDTH + (FIELD_WIDTH_OFFSET * 2))
#define OFFNAO_FULL_FIELD_WIDTH (FIELD_WIDTH + (OFFNAO_FIELD_WIDTH_OFFSET * 2))

/** Ball Dimensions */
#define BALL_RADIUS 50

/** Post positions in AbsCoord */
#define GOAL_POST_ABS_X (FIELD_LENGTH / 2.0) - (FIELD_LINE_WIDTH / 2.0) + (GOAL_POST_DIAMETER / 2.0)  // the front of the goal post lines up with the line (as shown in spl rule book)
#define GOAL_POST_ABS_Y (GOAL_WIDTH / 2)

/** Goal Free Kick Positions in AbsCoord */
#define GOAL_FREE_KICK_ABS_X PENALTY_CROSS_ABS_X
#define GOAL_FREE_KICK_ABS_Y (GOAL_BOX_WIDTH / 2)

/** Corner Kick Positions in AbsCoord */
#define CORNER_KICK_ABS_X (FIELD_LENGTH / 2)
#define CORNER_KICK_ABS_Y (FIELD_WIDTH / 2)
