require 'rails_helper'

describe City do

  it "1 城市维修能力 默认情况" do
    d1, d2 = City.date_range(nil, nil)

    d1.should === Date.tomorrow
    d2.should === 2.weeks.since.to_date
  end

  it "2 城市维修能力 start_at 小于当天的时候" do
    d1, d2 = City.date_range(1.days.ago.to_date, nil)

    d1.should === Date.today
    d2.should === 2.weeks.since.to_date
  end

  it "3 城市维修能力 start_at 小于当天, end_at 小于 start_at " do
    d1, d2 = City.date_range(1.days.ago.to_date, 2.day.ago.to_date)

    d1.should === Date.today
    d2.should === 2.weeks.since.to_date
  end

  it "4 城市维修能力 start_at 正好, end_at 小于 start_at " do
    d1, d2 = City.date_range(3.days.since.to_date, 2.day.since.to_date)

    d1.should === Date.today
    d2.should === 2.day.since.to_date
  end

  it "5 城市维修能力 start_at 小于当天, end_at 正好 " do
    d1, d2 = City.date_range(1.days.ago.to_date, 10.day.since.to_date)

    d1.should === Date.today
    d2.should === 10.day.since.to_date
  end

  it "6 城市维修能力 start_at 大于 end_at, end_at 正好 " do
    d1, d2 = City.date_range(11.days.since.to_date, 10.day.since.to_date)

    d1.should === Date.today
    d2.should === 10.day.since.to_date
  end

  it "7 城市维修能力 start_at 小于当天 end_at 大于2周后" do
    d1, d2 = City.date_range(1.days.ago.to_date, 16.days.since.to_date)

    d1.should === Date.today
    d2.should === 2.weeks.since.to_date
  end

  it "8 城市维修能力 end_at 大于2周后" do
    d1, d2 = City.date_range(2.days.since.to_date, 18.days.since.to_date)

    d1.should === 2.days.since.to_date
    d2.should === 2.weeks.since.to_date
  end

  it "9 城市维修能力 时间范围正好 " do
    day2 = 2.days.since.to_date
    day6 = 6.days.since.to_date

    d1, d2 = City.date_range(day2, day6)

    d1.should === day2
    d2.should === day6
  end
end
