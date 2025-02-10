
# Stints Metadata

## Variables

### Meeting Key
-   Id number for the race meeting. A meeting is an entire weekend of F1 racing.
-   Numeric
-   Ranges from 1229 to 12523

### Session Key
-   Id number for the racing session. There are five sessions for each meeting.
-   Numeric
-   Ranges from 9461 to 9673

### Stint Number
- Number referring to what stint the driver is on. One stint is a period between pit stops.
- Numeric
- Ranges from 1 to 9

### Driver Number

-   Number worn by the driver and on their car used to identify them
-   Numeric
-   Ranges from 1 to 97
- Two NA values

### Lap Start
- Number of the initial lap of this stint
- Numeric
- Ranges from 1 to 71

### Lap End
- Number of the last lap completed in this stint
- Numeric
- Ranges from 0 to 79

### Compound
- Specific compound of tire used in this stint
- Text
- Soft, Medium, or Hard

### Tyre Age At Start
- Age of the tires, in laps completed, at the beginning of this stint
- Numeric
- Ranges from to 28
- 33 missing values