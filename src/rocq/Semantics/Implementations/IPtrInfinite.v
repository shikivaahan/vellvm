From Vellvm Require Import
  Utils
  Syntax.

From Vellvm Require Import
  IPtr
  Integers
  VellvmIntegers.

(* Global, not local: [Params] has superclass fields [IPTR :: IPtr] and
   [IPTRT :: IPtrTheory], so with no concrete [IPtr] instance in the
   database, typeclass resolution cycles
   [IPtr -> Params (projection) -> ParamsV -> IPtr -> ...],
   shelving thousands of subgoals per turn and exhausting memory
   (e.g. elaborating [bind (write_bytes p bs) k] under [memM_interp]).
   The infinite-pointer model is Vellvm's canonical default (cf.
   [TopLevel.interpreter]); the finite variant stays opt-in. *)
#[global] Instance IPZ : IPtr :=
  {|
    iptr := Z;
    zero_iptr := 0%Z;

    eq_dec_iptr := Z.eq_dec;
    eqb_iptr := Z.eqb;
    to_Z x := x;

    VMemInt_iptr := VMemInt_Z;

    (* TODO: negatives;;;; ???? *)
    to_unsigned p := p;
    from_Z (x : Z) := ret x;

    show_iptr p := show p;
  |}.

#[global] Instance IPZTheory : IPtrTheory.
Proof.
  constructor; cbn; auto.
  - intros z i FROM; inversion FROM; auto.
  - intros z1 z2 i Z1 Z2; inversion Z1; inversion Z2; subst; auto.
Qed.

(* Re-register at the head of the cost-0 bucket: the [Params] superclass
   projection [IPTRT] otherwise sorts first, and typeclass resolution
   cycles [IPtrTheory -> IPTRT -> Params -> ParamsV -> IPtrTheory -> ...]
   (shelving thousands of subgoals per turn, exhausting memory) instead
   of finding this concrete instance. Same reason [IPZ] is global above. *)
Existing Instance IPZTheory.
