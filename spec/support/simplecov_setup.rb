# frozen_string_literal: true

require "simplecov"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  SimpleCov::Formatter::HTMLFormatter
)

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/bin/"
  add_filter "/vendor/"
  coverage_dir "spec/coverage"

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Interactors", "app/interactors"
  add_group "Config", "config"
end
