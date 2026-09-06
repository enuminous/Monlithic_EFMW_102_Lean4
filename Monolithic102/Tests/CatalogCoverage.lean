import Monolithic102.Catalog

namespace Monolithic102.Tests

theorem catalog_has_102 : catalog.length = 102 := by
  native_decide

theorem catalog_numbers_are_1_to_102 :
    catalog.map EquationSpec.number = List.range' 1 102 := by
  native_decide

end Monolithic102.Tests
