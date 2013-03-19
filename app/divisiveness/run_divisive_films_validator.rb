require 'app/divisiveness/divisive_films_validator'
require 'app/gf_data_loader'

divisive_films = [69036, 58109, 97034, 59397] # avatar, pulp fiction, the hangover, zoolander
gf_data_set = GfDataLoader.load_all()
gf_data_set.keep_only_n_top_rated_films(200)

divisive_films.map! { |film_id| gf_data_set.get_film_with_id(film_id) }
training_data_set = DivisiveFilmsValidator.get_data_set(gf_data_set, divisive_films)

tmp_file = 'D:/Goodfilms/sandpit/test_data.csv'
DivisiveFilmsValidator.write_data_set_to_file(training_data_set, tmp_file)