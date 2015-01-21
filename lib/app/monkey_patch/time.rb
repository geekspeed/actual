module MonkeyPatch
  module Time
    def app_format
      strftime("%d-%m-%Y")
    end

    def day_date_month
      strftime("%A, %d %b")
    end

    def date_month_year
      strftime("%d %m %Y")
    end

    def event_format
      strftime("%d %b %y")
    end
  end
end