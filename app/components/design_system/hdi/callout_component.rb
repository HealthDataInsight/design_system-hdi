module DesignSystem
  module Hdi
    # HDI warning callout. Matches the NHS-style callout but uses the HDI
    # visually-hidden utility class (no `-u-` infix), so it ships its own
    # template.
    class CalloutComponent < DesignSystem::Generic::CalloutComponent
    end
  end
end
