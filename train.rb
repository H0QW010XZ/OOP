class Train
  require './company'
  require './instance_counter'
  include Company
  include InstanceCounter
  attr_reader :speed, :type, :wagons, :number, :route
  @@all_trains = []
  def initialize(number, type)
    @number = number
    @type = type
    @speed = 0
    @wagons = []
    @route = nil
    @current_station = 0
    @@all_trains << self
    register_instance
  end

  def self.find(number)
    train_number = number.to_i
    find_train = @@all_trains.select { |train| train_number == train.number }
    find_train
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
    return puts 'Сбавьте скорость до 0' unless @speed.zero?

    @wagons << wagon
    puts 'Вагон успешно добавлен'
  end

  def delete_wagon(wagon)
    return puts 'Сбавьте скорость до 0' unless @speed.zero?
    return puts 'Кол-во вагонов не может быть отрицательным' if @wagons.empty?

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

  def move_straight
    return puts 'Станций больше нет' unless next_station
    return puts 'Скорость равна 0' if @speed.zero?

    current_station.delete_train(self)
    @current_station += 1
    current_station.accept_train(self)
  end

  def move_back
    return puts 'Станций больше нет' unless prev_station
    return puts 'Скорость равна 0' if @speed.zero?

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
end
