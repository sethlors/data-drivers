# Laps Metadata

## Variables

### date_start
- The UTC starting date and time, in ISO 8601 format.

### driver_number
- The unique number assigned to an F1 driver (cf. [Wikipedia](https://en.wikipedia.org/wiki/List_of_Formula_One_driver_numbers#Formula_One_driver_numbers)).

### duration_sector_1
- The time taken, in seconds, to complete the first sector of the lap.

### duration_sector_2
- The time taken, in seconds, to complete the second sector of the lap.

### duration_sector_3
- The time taken, in seconds, to complete the third sector of the lap.

### i1_speed
- The speed of the car, in km/h, at the first intermediate point on the track.

### i2_speed
- The speed of the car, in km/h, at the second intermediate point on the track.

### is_pit_out_lap
- A boolean value indicating whether the lap is an "out lap" from the pit (true if it is, false otherwise).

### lap_duration
- The total time taken, in seconds, to complete the entire lap.

### lap_number
- The sequential number of the lap within the session (starts at 1).

### meeting_key
- The unique identifier for the meeting. Use latest to identify the latest or current meeting.

### segments_sector_1
- A list of values representing the "mini-sectors" within the first sector (see mapping table below).

### segments_sector_2
- A list of values representing the "mini-sectors" within the second sector (see mapping table below).

### segments_sector_3
- A list of values representing the "mini-sectors" within the third sector (see mapping table below).

### session_key
- The unique identifier for the session. Use latest to identify the latest or current session.

### st_speed
- The speed of the car, in km/h, at the speed trap, which is a specific point on the track where the highest speeds are usually recorded.