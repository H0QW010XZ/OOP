class Train
  require './company'
  require './instance_counter'
  require './acсessors.rb'
  require './validation'
  include Company
  include InstanceCounter
  include Acсessors
  include Validation

  attr_reader :speed, :type, :wagons, :number, :route
  attr_accessor_with_history :color, :model
  strong_attr_accessor :number, String

  validate :number, :presence
  validate :number, :type, String
  validate :number, :format, /^([a-z]|\d){3}[-]?([a-z]|\d){2}$/

  @@all_trains = []
  def initialize(number, type)
    @number = number
    @type = type
    @speed = 0
    @wagons = []
    @route = nil
    @current_station = 0
    @color = 'red'
    @model = 'my_model'
    @test_strong = 1
    validate!
    @@all_trains << self
    register_instance
  end

  def self.find(number)
    train_number = number
    find_train = @@all_trains.select { |train| train_number == train.number }
    find_train
  end

  def self.validate!(number, _type)
    regexp = /^([a-z]|\d){3}[-]?([a-z]|\d){2}$/
    raise unless number =~ regexp
  end

  def self.valid?(number, type)
    validate!(number, type)
    true
  rescue StandardError
    false
  end

  def add_speed(speed)
    @speed += speed
  end

  def remove_speed(speed)
    if @speed - speed > 0
      @speed -= speed
    else
      puts 'Скорость не может быть отрицательной'
    end
  end

  def add_wagon(wagon)
    return false unless speed_valid?

    @wagons << wagon
    puts 'Вагон успешно добавлен'
  end

  def delete_wagon(wagon)
    return false unless speed_valid?
    return false if @wagons.empty?

    @wagons.delete(wagon)
    puts 'Вагон успешно удален'
  end

  def add_route(route)
    @route = route
    @route.from.accept_train(self)
  end

  def show_route
    puts @route.show_stations
  end

  def show_wagons
    @wagons.each_with_index do |wagon, i|
      puts "#{i} - #{wagon.number}, #{wagon.type}"
    end
  end

  def each_wagons_block
    @wagons.each do |wagon|
      yield(wagon)
    end
  end

  def move_straight
    return false unless next_station
    return false if @speed.zero?

    current_station.delete_train(self)
    @current_station += 1
    current_station.accept_train(self)
  end

  def move_back
    return false unless prev_station
    return false if @speed.zero?

    current_station.delete_train(self)
    @current_station -= 1
    current_station.accept_train(self)
  end

  def next_station
    @route.stations[@current_station + 1]
  end

  def prev_station
    @route.stations[@current_station - 1] unless @current_station.zero?
  end

  def stop
    @speed = 0
  end

  def current_station
    @route.stations[@current_station]
  end

  protected

  def speed_valid?
    raise unless @speed.zero?

    true
  rescue StandardError
    false
  end
end
