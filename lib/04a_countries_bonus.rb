# == Schema Information
#
# Table name: countries
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

# BONUS QUESTIONS: These problems require knowledge of aggregate
# functions. Attempt them after completing section 05.

def highest_gdp
  # Which countries have a GDP greater than every country in Europe? (Give the
  # name only. Some countries may have NULL gdp values)
  execute(<<-SQL)
    SELECT
      name
    FROM
      countries
    WHERE
      gdp > (
        SELECT
          MAX(gdp)
        FROM
          countries
        WHERE
          continent = 'Europe'
      )
  SQL
end

def largest_in_continent
  # Find the largest country (by area) in each continent. Show the continent,
  # name, and area.
  execute(<<-SQL)
    SELECT
      c.continent, c.name, c.area
    FROM
      countries AS c
    JOIN (
          SELECT
            continent, MAX(area) AS max
          FROM
            countries
          GROUP BY
            continent
          ) AS mpc
    ON
      c.continent = mpc.continent
    WHERE
      c.area = mpc.max
  SQL
end

def large_neighbors
  # Some countries have populations more than three times that of any of their
  # neighbors (in the same continent). Give the countries and continents.
  execute(<<-SQL)

  SELECT
    c1.name, c1.continent
  FROM
    countries AS c1
  JOIN (
    SELECT
      c.name, c.continent, c.population,
      RANK() OVER (PARTITION BY c.continent ORDER BY c.population DESC) AS rank
    FROM
      countries AS c
  ) AS cr
  ON
    (c1.continent = cr.continent)

  WHERE
    cr.rank = 2 AND (c1.population / cr.population >= 3)

    --
    -- SELECT
    --   *
    -- FROM (
    --   SELECT
    --     c.name, c.continent, c.population,
    --     RANK() OVER (PARTITION BY c.continent ORDER BY c.population DESC) AS rank
    --   FROM
    --     countries AS c
    -- ) AS cr1
    -- JOIN
    --   cr1 AS cr2 ON (cr1.continent = cr2.continent)
    -- WHERE
    --   cr1.rank = 1 AND cr2.rank = 2

  SQL
end
