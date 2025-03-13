pub const Activity = struct {
    id: u32,
    date: []u8,
    name: []u8,
    type: []u8, // Ride Run
    description: []u8,
    elapsed_time: u32, // 5601
    distance: f32, // 18.96
    // max_heart_rate: u8, // correct type?
    // relative_effort: u16, // correct type?
    commute: bool,
    private_note: []u8,
    gear: []u8, // bike shoes etc.
    filename: []u8,
    // athlete_weight: f16, // correct type?
    // bike_weight: f16, // correct type?
    // elapsed_time: f32,
    moving_time: u32, // 4567.0
    // distance: f32,
    max_speed: f32,
    avg_speed: f32,
    elevation_gain: f32,
    elevation_loss: f32,
    elevation_low: f32,
    elevation_high: f32,
    max_grade: f32,
    avg_grade: f32,
    avg_positive_grade: f32,
    avg_negative_grade: f32,
    // max_cadence: u16,
    // avg_cadence: f16,
    // max_heart_rate: u16,
    // avg_heart_rate: u16,
    // max_watts: u16,
    // avg_watts: u16,
    // calories: f32,
    max_temperature: i8,
    avg_temperature: i8,
    // relative_effort: u16, // correct type?
    total_work: u16, // correct type?
    number_of_runs: u16, // correct type?
    uphill_time: u16,
    downhill_time: u16,
    other_time: u16,
    perceived_exertion: u16,
    // type: u8, // correct type?
    start_time: u32,
    // weighted_avg_power: u16,
    // power_count: u16, // correct type?
    // prefer_perceid_exertion: f16, // correct type?
    // perceived_relative_effort: u16, // correct type?
    // commute: f16,
    // total_weight_lifted: f16,
    // From Upload
    // grade_adjustetd_distance: u16,
    // Weather observation time
    // Weather condition
    // weather_temperature: f32,
    // apparent_temperature: f32,
    // dewpoint: f32,
    // humidity: f32,
    // weather_pressure: f32,
    // wind_speed: f32,
    // wind_gust: f32,
    // wind_bearing: u16,
    // Percipation intensity
    // Sunrise time
    // Sunset time
    // Moon phase
    // Bike = 8,939,781.0
    // Gear
    // Precipitation Probability
    // Precipitation type
    // Cloud Cover
    // Weather visibility
    // UV index
    // Weather ozone
    // Jump count
    // Total grit
    // Average flow
    // flagged: u16,
    // avg_elapsed_speed: f32,
    // dirt_distance: f32,
    // Newly exported distance
    // Newly exported dirt distance
    // acitivity_count: u8,
    // total_steps: u32,
    // Carbon saved
    // Pool length
    // Tranining load
    // Intensity
    // avg_grade_adjusted_pace: f16,
    // timer_time: u32,
    // total_cycles: u16,
    media: []u8,
};
