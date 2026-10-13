import Lean
import Monolithic102
import Monolithic102.All
import Monolithic102.Catalog
import Monolithic102.Formalized
import Monolithic102.ME001
import Monolithic102.ME002
import Monolithic102.ME003
import Monolithic102.ME004
import Monolithic102.ME005
import Monolithic102.ME006
import Monolithic102.ME007
import Monolithic102.ME008
import Monolithic102.ME009
import Monolithic102.ME010
import Monolithic102.ME011
import Monolithic102.ME012
import Monolithic102.ME013
import Monolithic102.ME014
import Monolithic102.ME015
import Monolithic102.ME016
import Monolithic102.ME017
import Monolithic102.ME018
import Monolithic102.ME019
import Monolithic102.ME020
import Monolithic102.ME021
import Monolithic102.ME022
import Monolithic102.ME023
import Monolithic102.ME024
import Monolithic102.ME025
import Monolithic102.ME026
import Monolithic102.ME027
import Monolithic102.ME028
import Monolithic102.ME029
import Monolithic102.ME030
import Monolithic102.ME031
import Monolithic102.ME032
import Monolithic102.ME033
import Monolithic102.ME034
import Monolithic102.ME035
import Monolithic102.ME036
import Monolithic102.ME037
import Monolithic102.ME038
import Monolithic102.ME039
import Monolithic102.ME040
import Monolithic102.ME041
import Monolithic102.ME042
import Monolithic102.ME043
import Monolithic102.ME044
import Monolithic102.ME045
import Monolithic102.ME046
import Monolithic102.ME047
import Monolithic102.ME048
import Monolithic102.ME049
import Monolithic102.ME050
import Monolithic102.ME051
import Monolithic102.ME052
import Monolithic102.ME053
import Monolithic102.ME054
import Monolithic102.ME055
import Monolithic102.ME056
import Monolithic102.ME057
import Monolithic102.ME058
import Monolithic102.ME059
import Monolithic102.ME060
import Monolithic102.ME061
import Monolithic102.ME062
import Monolithic102.ME063
import Monolithic102.ME064
import Monolithic102.ME065
import Monolithic102.ME066
import Monolithic102.ME067
import Monolithic102.ME068
import Monolithic102.ME069
import Monolithic102.ME070
import Monolithic102.ME071
import Monolithic102.ME072
import Monolithic102.ME073
import Monolithic102.ME074
import Monolithic102.ME075
import Monolithic102.ME076
import Monolithic102.ME077
import Monolithic102.ME078
import Monolithic102.ME079
import Monolithic102.ME080
import Monolithic102.ME081
import Monolithic102.ME082
import Monolithic102.ME083
import Monolithic102.ME084
import Monolithic102.ME085
import Monolithic102.ME086
import Monolithic102.ME087
import Monolithic102.ME088
import Monolithic102.ME089
import Monolithic102.ME090
import Monolithic102.ME091
import Monolithic102.ME092
import Monolithic102.ME093
import Monolithic102.ME094
import Monolithic102.ME095
import Monolithic102.ME096
import Monolithic102.ME097
import Monolithic102.ME098
import Monolithic102.ME099
import Monolithic102.ME100
import Monolithic102.ME101
import Monolithic102.ME102
import Monolithic102.Schema

/-! Audit every safe declaration defined in the listed project modules. -/

open Lean in
run_cmd do
  let env ← getEnv
  let modules : Array Name := #[`Monolithic102, `Monolithic102.All, `Monolithic102.Catalog, `Monolithic102.Formalized, `Monolithic102.ME001, `Monolithic102.ME002, `Monolithic102.ME003, `Monolithic102.ME004, `Monolithic102.ME005, `Monolithic102.ME006, `Monolithic102.ME007, `Monolithic102.ME008, `Monolithic102.ME009, `Monolithic102.ME010, `Monolithic102.ME011, `Monolithic102.ME012, `Monolithic102.ME013, `Monolithic102.ME014, `Monolithic102.ME015, `Monolithic102.ME016, `Monolithic102.ME017, `Monolithic102.ME018, `Monolithic102.ME019, `Monolithic102.ME020, `Monolithic102.ME021, `Monolithic102.ME022, `Monolithic102.ME023, `Monolithic102.ME024, `Monolithic102.ME025, `Monolithic102.ME026, `Monolithic102.ME027, `Monolithic102.ME028, `Monolithic102.ME029, `Monolithic102.ME030, `Monolithic102.ME031, `Monolithic102.ME032, `Monolithic102.ME033, `Monolithic102.ME034, `Monolithic102.ME035, `Monolithic102.ME036, `Monolithic102.ME037, `Monolithic102.ME038, `Monolithic102.ME039, `Monolithic102.ME040, `Monolithic102.ME041, `Monolithic102.ME042, `Monolithic102.ME043, `Monolithic102.ME044, `Monolithic102.ME045, `Monolithic102.ME046, `Monolithic102.ME047, `Monolithic102.ME048, `Monolithic102.ME049, `Monolithic102.ME050, `Monolithic102.ME051, `Monolithic102.ME052, `Monolithic102.ME053, `Monolithic102.ME054, `Monolithic102.ME055, `Monolithic102.ME056, `Monolithic102.ME057, `Monolithic102.ME058, `Monolithic102.ME059, `Monolithic102.ME060, `Monolithic102.ME061, `Monolithic102.ME062, `Monolithic102.ME063, `Monolithic102.ME064, `Monolithic102.ME065, `Monolithic102.ME066, `Monolithic102.ME067, `Monolithic102.ME068, `Monolithic102.ME069, `Monolithic102.ME070, `Monolithic102.ME071, `Monolithic102.ME072, `Monolithic102.ME073, `Monolithic102.ME074, `Monolithic102.ME075, `Monolithic102.ME076, `Monolithic102.ME077, `Monolithic102.ME078, `Monolithic102.ME079, `Monolithic102.ME080, `Monolithic102.ME081, `Monolithic102.ME082, `Monolithic102.ME083, `Monolithic102.ME084, `Monolithic102.ME085, `Monolithic102.ME086, `Monolithic102.ME087, `Monolithic102.ME088, `Monolithic102.ME089, `Monolithic102.ME090, `Monolithic102.ME091, `Monolithic102.ME092, `Monolithic102.ME093, `Monolithic102.ME094, `Monolithic102.ME095, `Monolithic102.ME096, `Monolithic102.ME097, `Monolithic102.ME098, `Monolithic102.ME099, `Monolithic102.ME100, `Monolithic102.ME101, `Monolithic102.ME102, `Monolithic102.Schema]
  let allowed : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut count := 0
  let mut theoremCount := 0
  for (name, info) in env.constants.toList do
    let isProject := match env.getModuleIdxFor? name with
      | some idx => modules.contains env.header.moduleNames[idx.toNat]!
      | none => (`AuditProbe).isPrefixOf (privateToUserName name)
    if isProject && !info.isUnsafe then
      count := count + 1
      if info matches .thmInfo _ then
        theoremCount := theoremCount + 1
      for ax in (← collectAxioms name) do
        unless allowed.contains ax do
          throwError "Unapproved axiom {ax} used by {name}"
  if count == 0 then
    throwError "Audit matched no project declarations"
  logInfo m!"Axiom audit passed: {count} safe declarations, {theoremCount} theorem declarations (including generated lemmas)."
