namespace Monolithic102

inductive FormalStatus where
  | formalized
  | partiallyFormalized
  | needsSpecification
  | sourceOnly
  deriving Repr, DecidableEq, Inhabited

structure EquationSpec where
  number : Nat
  canonicalId : String
  title : String
  sourceTag : String
  sourceExpression : String
  descriptor : String
  status : FormalStatus
  note : String := ""
  deriving Repr, Inhabited

end Monolithic102
