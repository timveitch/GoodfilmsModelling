require 'app/gf_data_set'

class DivisiveFilmsValidator
  def self.get_validation(gf_data_set, divisive_films)
    get_data_set(gf_data_set, divisive_films)

  end

  def self.get_data_set(gf_data_set, divisive_films)
    # construct data set
    # variables = film rating, dummy for each film, user rating of divisive films
    puts 'Constructing data set for evaluation of divisive films'

    default_record = divisive_films.inject({}) { |hash, divisive_film|
      hash["c_quality_#{divisive_film.film_id}".to_sym] = -1
      hash["c_rewatch_#{divisive_film.film_id}".to_sym] = -1
      hash
    }

    records = gf_data_set.ratings.map { |rating|
      next if divisive_films.include?(rating.film)
      record = default_record.dup
      record[:a_quality_rating]        = rating.quality_rating
      record[:a_rewatch_rating] = rating.rewatchability_rating

      record["b_is_film_#{rating.film.film_id}".to_sym] = 1

      rating.user.ratings.each { |rating|
        if divisive_films.include?(rating.film)
          record["c_quality_#{rating.film.film_id}".to_sym] = rating.quality_rating
          record["c_rewatch_#{rating.film.film_id}".to_sym] = rating.rewatchability_rating
        end
      }
      record
    }
    records.compact!
    return records
  end

  def self.write_data_set_to_file(records, output_file)
    fields = records.inject({}) { |hash, record|
      record.keys.each { |key| hash[key] = true }
      hash
    }.keys.map(&:to_s).sort.map(&:to_sym)

    File.open(output_file, 'w') { |output|
      output.puts fields.join(',')
      records.each { |record|
        row = fields.map { |field| record.fetch(field, 0) }
        output.puts row.join(',')
      }
    }
  end
end