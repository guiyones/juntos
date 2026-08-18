module ApplicationHelper
  def greeting
    case Time.current.hour
    when 5..11 then "Bom dia"
    when 12..17 then "Boa tarde"
    else "Boa noite"
    end
  end
end
