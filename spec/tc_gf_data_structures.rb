require 'test/unit'
require 'tmpdir'
require 'app/gf_data_structures'

class TcGfDataStructures < Test::Unit::TestCase
  def setup
    @tmp_file = File.join(Dir.tmpdir, 'temp.csv')
    File.open(@tmp_file, 'w') { |output|
      output.puts 'a,b,c,d'
      output.puts '1,2,3,4'
    }
  end

  def teardown
    File.delete(@tmp_file)
  end

  def test_struct_creation
    tmp_struct = create_struct_from_file_header(@tmp_file)
    assert_equal(['a','b','c','d'], tmp_struct.members, 'struct fields')
  end

  def test_struct_creation_with_extra_fields()
    tmp_struct = create_struct_from_file_header(@tmp_file,[:e])
    assert_equal(['a','b','c','d','e'], tmp_struct.members, 'struct fields with extra')
  end
end