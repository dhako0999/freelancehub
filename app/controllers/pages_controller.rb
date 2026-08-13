class PagesController < ApplicationController

  allow_unauthenticated_access only: %i[home about contact]

  def home
    @title = "AI Client Portal"
    @developer = "Johnny Doe"
    @year = 2026
  end

  def about
  end

  def contact
  end
end
