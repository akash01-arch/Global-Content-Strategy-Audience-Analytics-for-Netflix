CREATE TABLE netflix_titles (
    show_id VARCHAR(10) PRIMARY KEY,
    type VARCHAR(10),
    title TEXT,
    director TEXT,
    cast_members TEXT,      -- Renamed from 'cast'
    country TEXT,
    date_added TEXT,        -- Changed to TEXT for safe import
    release_year INT,
    rating VARCHAR(10),
    duration TEXT,
    listed_in TEXT,
    description TEXT,
    primary_country TEXT,
    duration_value INT,
    duration_unit VARCHAR(20),
    duration_minutes INT,
    duration_seasons INT,
    year_added INT,
    month_added INT,
    day_added INT,
    quarter_added INT,
    year_gap INT,
    content_age INT,
    is_recent_content INT,
    primary_genre TEXT,
    movie_length_category TEXT,
    tv_length_category TEXT,
    time_to_netflix INT,
    has_international_cast INT,
    genre_count INT,
    age_target TEXT,
    production_era TEXT,
    is_netflix_original INT
);

COPY netflix_titles
FROM 'E:\Netflix Project\clean-netflix-dataset.csv' 
DELIMITER ','
CSV HEADER;

CREATE INDEX idx_type ON netflix_titles(type);
CREATE INDEX idx_year_added ON netflix_titles(year_added);
CREATE INDEX idx_primary_country ON netflix_titles(primary_country);
CREATE INDEX idx_primary_genre ON netflix_titles(primary_genre);
CREATE INDEX idx_release_year ON netflix_titles(release_year);
CREATE INDEX idx_rating ON netflix_titles(rating);
CREATE INDEX idx_is_netflix_original ON netflix_titles(is_netflix_original);

-- 3.1 Movies vs TV Shows Distribution
SELECT
    type,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM netflix_titles
GROUP BY type;
-- Insight: Movies dominate in volume, while TV Shows support long-term engagement.

-- 3.2 Average Movie Runtime (Minutes)
SELECT
    ROUND(AVG(duration_minutes), 2) AS avg_movie_runtime_minutes,
    MIN(duration_minutes) AS min_runtime,
    MAX(duration_minutes) AS max_runtime,
    ROUND(STDDEV(duration_minutes), 2) AS std_dev_runtime
FROM netflix_titles
WHERE type = 'Movie'
  AND duration_minutes IS NOT NULL;

-- 3.3 Average TV Show Length (Seasons)  
SELECT
    ROUND(AVG(duration_seasons), 2) AS avg_tv_show_seasons,
    MIN(duration_seasons) AS min_seasons,
    MAX(duration_seasons) AS max_seasons
FROM netflix_titles
WHERE type = 'TV Show'
  AND duration_seasons IS NOT NULL;

-- 3.4 Movie Length Categories
SELECT
    movie_length_category,
    COUNT(*) AS total_movies,
    ROUND(AVG(duration_minutes), 2) AS avg_duration
FROM netflix_titles
WHERE type = 'Movie'
GROUP BY movie_length_category
ORDER BY total_movies DESC;
-- Insight: Most movies fall into short-to-medium length categories (90-120 min).

-- 3.5 TV Show Length Categories
SELECT
    tv_length_category,
    COUNT(*) AS total_tv_shows,
    ROUND(AVG(duration_seasons), 2) AS avg_seasons
FROM netflix_titles
WHERE type = 'TV Show'
GROUP BY tv_length_category
ORDER BY total_tv_shows DESC;

-- 3.6 Content Growth Over Time (Year Added)
SELECT
    year_added,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY year_added
ORDER BY year_added;
-- Insight: Sharp growth after 2016 reflects Netflix's global expansion phase.

-- 3.7 Quarterly Content Addition Trend
SELECT
    year_added,
    quarter_added,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY year_added, quarter_added
ORDER BY year_added, quarter_added;
-- Use Case: Release planning & seasonal strategy analysis.

-- 3.8 Top Content-Producing Countries
SELECT
    primary_country,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage
FROM netflix_titles
WHERE primary_country IS NOT NULL
  AND primary_country != 'Unknown'
GROUP BY primary_country
ORDER BY total_titles DESC
LIMIT 10;

-- 3.9 International Cast Analysis
SELECT
    has_international_cast,
    COUNT(*) AS total_titles,
    ROUND(AVG(genre_count), 2) AS avg_genres
FROM netflix_titles
GROUP BY has_international_cast;
-- Insight: Netflix increasingly promotes globally diverse casts.

-- 3.10 Top Genres
SELECT
    primary_genre,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage
FROM netflix_titles
GROUP BY primary_genre
ORDER BY total_titles DESC
LIMIT 10;

-- 3.11 Average Genre Count per Title
SELECT
    ROUND(AVG(genre_count), 2) AS avg_genres_per_title,
    MIN(genre_count) AS min_genres,
    MAX(genre_count) AS max_genres
FROM netflix_titles;
-- Insight: Most content spans multiple genres, improving recommendation diversity.

-- 3.12 Age Target Analysis
SELECT
    age_target,
    COUNT(*) AS total_titles,
    ROUND(AVG(duration_minutes), 2) AS avg_movie_duration
FROM netflix_titles
GROUP BY age_target
ORDER BY total_titles DESC;
-- Insight: Netflix primarily targets young-adult and mature audiences.

-- 3.13 Production Era Distribution
SELECT
    production_era,
    COUNT(*) AS total_titles,
    MIN(release_year) AS earliest_year,
    MAX(release_year) AS latest_year
FROM netflix_titles
GROUP BY production_era
ORDER BY total_titles DESC;
-- Insight: Majority of content comes from modern digital-era productions.

-- 3.14 Netflix Originals vs Licensed Content
SELECT
    CASE 
        WHEN is_netflix_original = 1 THEN 'Netflix Original'
        ELSE 'Licensed Content'
    END AS content_source,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage,
    ROUND(AVG(time_to_netflix), 2) AS avg_time_to_platform
FROM netflix_titles
GROUP BY is_netflix_original;
-- Insight: Strong investment trend toward Netflix Originals.

-- 3.15 Time-to-Netflix Analysis
SELECT
    type,
    ROUND(AVG(time_to_netflix), 2) AS avg_years_to_platform,
    MIN(time_to_netflix) AS min_years,
    MAX(time_to_netflix) AS max_years
FROM netflix_titles
GROUP BY type;
-- Insight: Movies typically reach Netflix faster than TV shows.

-- 3.16 Content Freshness Analysis
SELECT
    CASE 
        WHEN is_recent_content = 1 THEN 'Recent (Within 1 Year)'
        ELSE 'Older Content'
    END AS content_freshness,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage
FROM netflix_titles
GROUP BY is_recent_content;
-- Insight: Netflix balances legacy content with recent releases.

-- 3.17 Content Age Distribution
SELECT
    content_age,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY content_age
ORDER BY content_age;

