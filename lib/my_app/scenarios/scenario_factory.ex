defmodule MyApp.Scenarios.ScenarioFactory do
  @moduledoc """
  Factory for mapping scenario atoms to their corresponding modules.
  """

  @type scenario :: :restaurant
  @type scenario_module :: module()

  @doc """
  Returns the module corresponding to the given scenario atom.

  ## Parameters
  - scenario: Atom identifying the scenario (e.g., :restaurant)
  """
  @spec get_module(scenario) :: scenario_module
  def get_module(scenario) do
    case scenario do
      :restaurant -> MyApp.Scenarios.RestaurantScenario
      :supermarket -> MyApp.Scenarios.SupermarketScenario
      :train_station -> MyApp.Scenarios.TrainStationScenario
      _ -> raise "Unknown scenario: #{scenario}"
    end
  end

  @doc """
  Returns a list of all available scenario atoms.
  """
  @spec list_scenarios() :: [scenario]
  def list_scenarios() do
    [:restaurant, :supermarket, :train_station]
  end
end
