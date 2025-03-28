
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
      _ -> raise "Unknown scenario: #{scenario}"
    end
  end
end
