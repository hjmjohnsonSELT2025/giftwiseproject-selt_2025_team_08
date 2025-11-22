module ApplicationHelper
  def calculate_age(date_of_birth)
    return 0 unless date_of_birth

    today = Date.today
    age = today.year - date_of_birth.year
    age -= 1 if today < date_of_birth.change(year: today.year)
    age
  end
end
