(*
This file is part of the Kind verifier

* Copyright (c) 2007-2013 by the Board of Trustees of the University of Iowa, 
* here after designated as the Copyright Holder.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the University of Iowa, nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

open Lib

(* We have three hashconsed types: uninterpreted function symbols,
   symbols and terms. Hashconsing has been extended to store a record
   of properties with each value, here we store mainly type
   information. 

   Uninterpreted function symbols are hashconsed separately, since
   they need to be declared in each solver instance. A hashconsed
   uninterpreted function symbol stores its type and by iterating over
   or folding the hashcons table we can obtain the necessary
   declarations.

   Symbols are hashconsed so that we can rely on physical equality for
   comparison, as of now there are no useful properties to be stored
   alongside symbols. In particular the `NUMERAL i, `DECIMAL f and
   `SYM (s, t) symbols need to be hashconsed for physical equality. 

   Terms are hashconsed for maximal sharing, comparison with physical
   equality and to store type information.

   For all three types hashtables, maps and set are provided. *)


(* ********************************************************************* *)
(* Types and hash-consing                                                *)
(* ********************************************************************* *)


(* Basic types for terms, input module for {!Ltree.Make} functor *)
module BaseTypes =
struct 

  (* Hashconsed symbols *)
  type symbol = Symbol.t

  (* Hashconsed variables *)
  type var = Var.t

  (* Hashconsed types *)
  type sort = Type.t

  (* Hashconsed attributes *)
  type attr = TermAttr.t

  (* Hash value of a symbol *)
  let hash_of_symbol = Symbol.hash_symbol 

  (* Hash value of a variable *)
  let hash_of_var = Var.hash_var 

  (* Hash value of a sort *)
  let hash_of_sort = Type.hash_type 

  (* Hash value of an attribute *)
  let hash_of_attr = TermAttr.hash_attr 

  (* Get sort of a variable *)
  let sort_of_var = Var.type_of_var

  let import_symbol = Symbol.import 

  let import_var = Var.import 

  let import_sort = Type.import 

  (* Pretty-print a symbol *)
  let pp_print_symbol = Symbol.pp_print_symbol

  (* Pretty-print a variable *)
  let pp_print_var = Var.pp_print_var

  (* Pretty-print a type *)
  let pp_print_sort = Type.pp_print_type

  (* Pretty-print an attribute *)
  let pp_print_attr = TermAttr.pp_print_attr

end


(* AST with base types *)
module T = Ltree.Make (BaseTypes)

(* Hashconsed term over symbols, variables and sorts *)
type t = T.t


(* Return the type of a term *)
let node_of_term = T.node_of_t


(* Flatten top node of term *)
let destruct = T.destruct


(* Return true if the term is a free variable *)
let is_free_var t = match node_of_term t with
  | T.FreeVar _ -> true 
  | _ -> false 


(* Return the variable of a free variable term *)
let free_var_of_term t = match node_of_term t with
  | T.FreeVar v -> v
  | _ -> invalid_arg "free_var_of_term"


(* Return true if the term is a bound variable *)
let is_bound_var t = match node_of_term t with
  | T.BoundVar _ -> true 
  | _ -> false 


(* Return true if the term is a leaf symbol *)
let is_leaf t = match node_of_term t with
  | T.Leaf _ -> true 
  | _ -> false 


(* Return the symbol of a leaf term *)
let leaf_of_term t = match node_of_term t with
  | T.Leaf s -> s
  | _ -> invalid_arg "leaf_of_term"


(* Return true if the term is a function application *)
let is_node t = match node_of_term t with
  | T.Node _ -> true 
  | _ -> false 


(* Return the symbol of a function application *)
let node_symbol_of_term t = match node_of_term t with
  | T.Node (s, _) -> s 
  | _ -> invalid_arg "node_symbol_of_term"


(* Return the arguments of a function application *)
let node_args_of_term t = match node_of_term t with
  | T.Node (_, l) -> l 
  | _ -> invalid_arg "node_args_of_term"


(* Return true if the term is a let binding *)
let is_let t = match node_of_term t with
  | T.Let _ -> true 
  | _ -> false 


(* Return true if the term is an existential quantifier *)
let is_exists t = match node_of_term t with
  | T.Exists _ -> true 
  | _ -> false 


(* Return true if the term is a universal quantifier *)
let is_forall t = match node_of_term t with
  | T.Forall _ -> true 
  | _ -> false 



(* ********************************************************************* *)
(* Hashtables, maps and sets                                             *)
(* ********************************************************************* *)


(* Comparison function on terms *)
let compare = T.compare


(* Equality function on terms *)
let equal = T.equal


(* Hashing function on terms *)
let hash = T.hash 


(* Hashtable *)
module TermHashtbl = Hashtbl.Make (T)


(* Set 

   TODO: Try patricia trees over hashcons tags for sets *)
module TermSet = Set.Make (T)


(* Map *)
module TermMap = Map.Make (T)


(* ********************************************************************* *)
(* Pretty-printing                                                       *)
(* ********************************************************************* *)


(* Pretty-print a term *)
let pp_print_term ppf t = T.pp_print_term ppf t

(* Pretty-print a hashconsed term to the standard formatter *)
let print_term t = pp_print_term Format.std_formatter t

(* Return a string representation of a term *)
let string_of_term t = string_of_t pp_print_term t
(*
(* Pretty-print a term in infix notation *)
let pp_print_term_infix = T.pp_print_term_infix ppf t
*)
(* Pretty-print a hashconsed term to the standard formatter *)
let print_term t = pp_print_term Format.std_formatter t

(* Return a string representation of a term *)
let string_of_term t = string_of_t pp_print_term t

  

(* ********************************************************************* *)
(* Type checking for terms                                               *)
(* ********************************************************************* *)


(* Return the type of a term node 

   TODO: handle IntRange type correctly 
*)
let rec type_of_term t = match T.destruct t with

  (* Return declared type of variable *)
  | T.Var v -> Var.type_of_var v

  (* Return type of a constant *)
  | T.Const s -> 

    (

      (* Get symbol *)
      match Symbol.node_of_symbol s with 

        (* Boolean constants *)
        | `TRUE 
        | `FALSE -> Type.mk_bool ()
            
        (* Integer constant *)
        | `NUMERAL _ -> Type.mk_int ()

        (* Real constant *)
        | `DECIMAL _ -> Type.mk_real ()

        (* Bitvector constant *)
        | `BV b -> Type.mk_bv (length_of_bitvector b)
          
        (* Uninterpreted constant *)
        | `UF s -> UfSymbol.res_type_of_uf_symbol s

        (* No other symbols are nullary *)
        | _ -> assert false 

    )

  (* Return type of a function application *)
  | T.App (s, l) -> 
    
    (

      (* Get symbol *)
      match Symbol.node_of_symbol s with 

        (* Boolean-valued functions *)
        | `NOT 
        | `IMPLIES
        | `AND
        | `OR
        | `XOR
        | `IS_INT
        | `EQ
        | `DISTINCT
        | `LEQ
        | `LT
        | `GEQ
        | `GT
        | `DIVISIBLE _
        | `BVULT -> Type.mk_bool ()

        (* Integer-valued functions *)
        | `TO_INT
        | `MOD
        | `ABS
        | `INTDIV -> Type.mk_int ()
          
        (* Real-valued functions *)
        | `TO_REAL
        | `DIV -> Type.mk_real ()
          
        (* Bitvector-valued function *)
        | `CONCAT -> 

          (match l with 

            (* Concat is binary *)
            | [a; b] -> 
              
              (* Compute width of resulting bitvector *)
              (match 
                  (Type.node_of_type (type_of_term a), 
                   Type.node_of_type (type_of_term b))
               with
                 | Type.BV i, Type.BV j -> 
                  Type.mk_bv 
                    (numeral_of_int ((int_of_numeral i) + (int_of_numeral j)))
                | _ -> assert false)
                
            | _ -> assert false)
     
            
        (* Bitvector-valued function *)
        | `EXTRACT (i, j) -> 
          
          (* Compute width of resulting bitvector *)
          Type.mk_bv 
            ((numeral_of_int ((int_of_numeral j) - (int_of_numeral i) + 1)))
            
        (* Array-valued function *)
        | `SELECT -> 

          (match l with 

            (* Select is binary *)
            | [a; _] -> 
    
              (match Type.node_of_type (type_of_term a) with
                | Type.Array (_, t) -> t
                | _ -> assert false)

            | _ -> assert false)

        (* Return type of first argument *)
        | `MINUS
        | `PLUS
        | `TIMES
        | `BVNOT
        | `BVNEG
        | `BVAND
        | `BVOR
        | `BVADD
        | `BVMUL
        | `BVDIV
        | `BVUREM
        | `BVSHL
        | `BVLSHR
        | `STORE -> 

          (match l with 
              
            (* Function must be at least binary *)
            | a :: _ -> type_of_term a
            | _ -> assert false)

        (* Return type of second argument *)
        | `ITE -> 

          (match l with 

            (* ite must be ternary *)
            | [_; a; _] -> type_of_term a
            | _ -> assert false)
            
        (* Uninterpreted constant *)
        | `UF s -> UfSymbol.res_type_of_uf_symbol s
            
        (* Ill-formed terms *)
        | `TRUE
        | `FALSE
        | `NUMERAL _
        | `DECIMAL _
        | `BV _ -> assert false

    )

  (* Return type of term *)
  | T.Attr (t, _) -> type_of_term t


(* Type checking disabled

   TODO: re-implement this with a function Types.subtype and allow
   IntRange as subtype of Int etc.

(* Return true of the list of types is valid for the symbol *)
let type_check_app s a = 

  match Symbol.node_of_symbol with

    (* Nullary function symbols *)
    | `TRUE
    | `FALSE
    | `NUMERAL _
    | `DECIMAL _
    | `BV _
        when List.length a = 0 -> true

    (* Unary polymorphic function symbols *)
    | `ATTR _
        when List.length a = 1 -> true

    (* Unary function of Boolean arguments *)
    | `NOT
        when a = [Type.Bool] -> true

    (* Unary function symbols of integer arguments *)
    | `ABS 
    | `TO_REAL 
    | `DIVISIBLE _ 
        when a = [Type.Int] -> true

    (* Unary function symbols of real arguments *)
    | `IS_INT 
    | `TO_INT 
        when a = [Type.Real] -> true

    (* Variadic, but at least binary function symbols of Boolean arguments *)
    | `IMPLIES 
    | `AND 
    | `OR 
    | `XOR 
        when 
          (List.for_all (Type.compatible Type.Bool) a) && 
            List.length a >= 2 -> true

    (* Ternary function symbol with first argument boolean and second
     and third arguments of identical type *)
    | `ITE -> 
      (match a with 
        | [p; t; f] 
            when 
              p = Type.Bool && 
              (Type.compatible t f) && 
              (Type.compatible f t) -> true
        | _ -> false)
        
  (* Polymorphic, variadic but at least binary function symbols with
     arguments of equal types *)
  | { Hashcons.node = `EQ }
  | { Hashcons.node = `DISTINCT }
      when List.length a >= 2 
        && (List.for_all (Type.compatible (List.hd a)) a) -> true

  (* Variadic but at least unary function symbols of all real or all
     integer arguments *)
  | { Hashcons.node = `MINUS }
      when List.length a >= 1 
        && 
          (match List.hd a with 
            | Type.Real 
            | Type.Int -> true 
            | _ -> false)
        && (List.for_all (Type.compatible (List.hd a)) a) -> true
    
  (* Variadic, but at least binary function symbols of all real or all
     integer arguments *)
  | { Hashcons.node = `PLUS }
  | { Hashcons.node = `TIMES }
  | { Hashcons.node = `LEQ }
  | { Hashcons.node = `LT }
  | { Hashcons.node = `GEQ }
  | { Hashcons.node = `GT }
      when List.length a >= 2
        && 
          (match List.hd a with 
            | Type.Real 
            | Type.Int -> true 
            | _ -> false)
        && (List.for_all (Type.compatible (List.hd a)) a) -> true

  (* Variadic, but at least binary function symbols of real arguments *)
  | { Hashcons.node = `DIV }
      when (List.for_all (Type.compatible Type.Real) a) && List.length a >= 2 -> true
    
  (* Variadic, but at least binary function symbols of integer arguments *)
  | { Hashcons.node = `INTDIV }
  | { Hashcons.node = `MOD }
      when (List.for_all (Type.compatible Type.Int) a) && List.length a >= 2 -> true


  (* Function symbol with a defined signature of fixed arity *)
  | { Hashcons.node = `UF s }
      when (UfSymbol.arg_type_of_uf_symbol s) = a -> true

  | _ -> false

*)

(* ********************************************************************* *)
(* Constructors                                                          *)
(* ********************************************************************* *)


(* Return a hashconsed constant *)
let mk_const = T.mk_const


(* Return a hashconsed variable *)
let mk_var = T.mk_var


(* Return a hashconsed function application

   TODO: type check arguments *)
let mk_app = T.mk_app
      

(* Return a hashconsed tree *)
let mk_term = T.mk_term


(* Return a hashconsed let binding *)
let mk_let  = T.mk_let


(* Return a hashconsed existentially quantified term *)
let mk_exists = T.mk_exists 


(* Return a hashconsed universally quantified term *)
let mk_forall = T.mk_forall


(* Import a term from a different instance into this hashcons table *)
let import = T.import 

(* Flatten top node of term *)
let construct = T.construct


(* Is the term a Boolean atom? *)
let rec is_atom t = match T.destruct t with 

  (* Function application *)
  | T.App (s, l) -> 

    (* Must be of Boolean type *)
    (type_of_term t == Type.mk_bool ()) &&

    (* All subterms must be not Boolean *)
    (List.for_all
       (function e -> 
         T.eval_t
           (function 

             (* Function application *)
             | T.App (s, l) as f -> 

               (function r -> 

                 (* Must not be of Boolean type *)
                 (not 
                    (type_of_term (T.construct f) == 
                       Type.mk_bool ())) &&

                 (* All subterms must not be of Boolean type *)
                 (List.for_all
                    (function t -> 
                      not (type_of_term t == Type.mk_bool ()))
                    l) &&

                 (* All subterms must be atoms *)
                 (List.fold_left (fun a e -> a && e) true r))

             (* Constant must not be of Boolean type *)
             | T.Const _ as f -> 

               (function 
                 | [] -> 
                   (not 
                      (type_of_term (T.construct f) == 
                         Type.mk_bool ()))
                 | _ -> assert false)

             (* Variable must not be of Boolean type *)
             | T.Var v -> 

               (function 
                 | [] -> 
                   (not (Var.type_of_var v == Type.mk_bool ()))
                 | _ -> assert false)

             (* Annotated term *)
             | T.Attr (t, _) -> (function _ -> is_atom t))

           e)
       l)

  (* A constant is a Boolean atom if it is of Boolean type *)
  | T.Const _ -> type_of_term t == Type.mk_bool ()

  (* A variable is a Boolean atom if it is of Boolean type *)
  | T.Var v -> Var.type_of_var v == Type.mk_bool ()

  (* Annotated term *)
  | T.Attr (t, _) -> is_atom t



(* Return true if the top symbol of the term is a negation *)
let is_negated term = match T.destruct term with
  | T.App (s, _) when s == Symbol.s_not -> true
  | _ -> false


(* Return a hashconsed constant *)
let mk_const_of_symbol_node s = 

  (* Hashcons the symbol and construct a constant term *)
  let s' = Symbol.mk_symbol s in mk_const s'


(* Return a hashconsed function application *)
let mk_app_of_symbol_node s a = 

  (* Hashcons the symbol and construct an application term *)
  let s' = Symbol.mk_symbol s in mk_app s' a


(* Return the hashconsed propositional constant true *)
let mk_true () = mk_const_of_symbol_node `TRUE


(* Keep a the hashconsed true as a value *)
let t_true = mk_true ()


(* Return the hashconsed propositional constant false *)
let mk_false () = mk_const_of_symbol_node `FALSE


(* Keep a the hashconsed false as a value *)
let t_false = mk_false ()


(* Hashcons a unary negation *)
let mk_not t = mk_app_of_symbol_node `NOT [t]


(* Hashcons an implication *)
let mk_implies = function
  | [] -> mk_false ()
  | [a] -> a
  | a -> mk_app_of_symbol_node `IMPLIES a


(* Hashcons an conjunction, accept nullary and unary conjunctions and
   convert to a propositional constant and return the single argument,
   respectively. *)
let mk_and = function
  | [] -> mk_true ()
  | [a] -> a
  | a -> mk_app_of_symbol_node `AND a 


(* Hashcons a disjunction, accept nullary and unary disjunctions and
   convert to a propositional constant and return the single argument,
   respectively. *)
let mk_or = function 
  | [] -> mk_false ()
  | [a] -> a 
  | a -> mk_app_of_symbol_node `OR a 


(* Hashcons an exclusive disjunction, fail if list of arguments is
   empty and if only one argument given return it. *)
let mk_xor = function
  | [] -> invalid_arg "Term.mk_xor"
  | [a] -> a
  | a -> mk_app_of_symbol_node `XOR a 


(* Hashcons an equation, a chain of equations for arity greater than
   binary *)
let mk_eq a = mk_app_of_symbol_node `EQ a


(* Hashcons an pairwise disjointness predicate *)
let mk_distinct a = mk_app_of_symbol_node `DISTINCT a


(* Hashcons a ternary if-then-else expression *)
let mk_ite p l r = mk_app_of_symbol_node `ITE [p; l; r]


(* Hashcons a unary minus or higher arity minus *)
let mk_minus a = mk_app_of_symbol_node `MINUS a


(* Hashcons an integer numeral *)
let mk_num n = mk_const_of_symbol_node (`NUMERAL n)


(* Hashcons an integer numeral given an integer *)
let mk_num_of_int = function

  (* Positive numeral or zero *)
  | i when i >= 0 -> 
    mk_const_of_symbol_node (`NUMERAL (numeral_of_int i))

  (* Wrap a negative numeral in a unary minus *)
  | i -> 
    mk_minus [(mk_const_of_symbol_node (`NUMERAL (numeral_of_int (- i))))]
      

(* Hashcons a real decimal *)
let mk_dec d = mk_const_of_symbol_node (`DECIMAL d)


(* Hashcons a floating-point decimal given a float *)
let mk_dec_of_float = function

  (* Positive decimal *)
  | f when f >= 0. -> 
    mk_const_of_symbol_node (`DECIMAL (decimal_of_float f))

  (* Negative decimal *)
  | f -> 
    mk_minus [mk_const_of_symbol_node (`DECIMAL (decimal_of_float (-. f)))]


(* Hashcons a bitvector *)
let mk_bv b = mk_const_of_symbol_node (`BV b)


(* Hashcons an addition *)
let mk_plus = function
  | [] -> invalid_arg "Term.mk_plus"
  | [a] -> a
  | a -> mk_app_of_symbol_node `PLUS a


(* Hashcons a multiplication *)
let mk_times = function
  | [] -> invalid_arg "Term.mk_times"
  | [a] -> a
  | a -> mk_app_of_symbol_node `TIMES a


(* Hashcons a real division *)
let mk_div = function
  | [] -> invalid_arg "Term.mk_div"
  | [a] -> a
  | a -> mk_app_of_symbol_node `DIV a


(* Hashcons an integer division *)
let mk_intdiv = function
  | [] -> invalid_arg "Term.mk_intdiv"
  | [a] -> a
  | a -> mk_app_of_symbol_node `INTDIV a


(* Hashcons a binary modulus operator *)
let mk_mod a b = mk_app_of_symbol_node `MOD [a; b]


(* Hashcons a unary absolute value function *)
let mk_abs t = mk_app_of_symbol_node `ABS [t]


(* Hashcons a binary less than or equal relation, a chain of relation
   for higher arities *)
let mk_leq = function
  | [] | [_] -> invalid_arg "Term.mk_leq"
  | a -> mk_app_of_symbol_node `LEQ a


(* Hashcons a binary less than relation, a chain of relation for higher
   arities *)
let mk_lt  = function
  | [] | [_] -> invalid_arg "Term.mk_lt"
  | a -> mk_app_of_symbol_node `LT a


(* Hashcons a binary greater than or equal relation, a chain of relations
   for higher arities *)
let mk_geq  = function
  | [] | [_] -> invalid_arg "Term.mk_geq"
  | a -> mk_app_of_symbol_node `GEQ a


(* Hashcons a binary greater than relation, a chain of relations for
   higher arities *)
let mk_gt  = function
  | [] | [_] -> invalid_arg "Term.mk_gt"
  | a -> mk_app_of_symbol_node `GT a


(* Hashcons a unary conversion to a real decimal *)
let mk_to_real t = mk_app_of_symbol_node `TO_REAL [t]


(* Hashcons a unary conversion to an integer numeral *)
let mk_to_int t = mk_app_of_symbol_node `TO_INT [t]


(* Hashcons a predicate for coincidence of a real with an integer *)
let mk_is_int t = mk_app_of_symbol_node `IS_INT [t]


(* Hashcons a divisibility predicate for the given divisor *)
let mk_divisible n t = mk_app_of_symbol_node (`DIVISIBLE n) [t]


(* Generate a new tag *)
let newid =
  let r = ref 0 in
  fun () -> incr r; !r


(* Hashcons a named term *)
let mk_named t = 

  (* Name term with its unique tag *)
  let n = newid () in

  (* Return name and named term

     Order pair in this way to put it an association list *)
  (n, T.mk_annot t (TermAttr.mk_named n))


(* Hashcons an uninterpreted function or constant *)
let mk_uf s = function 

  (* Create a constant for an empty list of arguments *)
  | [] -> mk_const_of_symbol_node (`UF s)

  (* Create a function application for non-empty list of arguments *)
  | a -> mk_app_of_symbol_node (`UF s) a

   
(* Hashcons a propositional constant *)
let mk_bool = function 
  | true -> mk_const_of_symbol_node `TRUE
  | false -> mk_const_of_symbol_node `FALSE


(* Hashcons an increment of the term one *)
let mk_succ t = mk_app_of_symbol_node `PLUS [t; (mk_num_of_int 1)]


(* Hashcons a decrement of the term by one *)
let mk_pred t = mk_app_of_symbol_node `MINUS [t; (mk_num_of_int 1)]


(* Hashcons a negation of the term, avoiding double negation *)
let negate t = match T.destruct t with 

  (* Top symbol is a negation, then remove negation 

     Must hashcons bottom-up since term was destructed and not all
     terms are necessarily in the hashcons table. *)
  | T.App (s, [t]) when s == Symbol.s_not -> t

  (* Top symbol is not a negation, then negate given term *)
  | _ -> mk_not t


(* Remove negation if it is the topmost symbol *)
let unnegate t = match T.destruct t with

  (* Top symbol is a negation, then remove negation 

     Must hashcons bottom-up since term was destructed and not all
     terms are necessarily in the hashcons table. *)
  | T.App (s, [t]) when s == Symbol.s_not -> t

  (* Top symbol is not a negation, then return unchanged *)
  | _ -> t 


(* Convert (= 0 (mod t n)) to (divisble n t) *)
let mod_to_divisible term = 

  let mod_to_divisible' t_mod = 
    
    match T.node_of_t t_mod with 
      
      (* Term is (mod t s) *)
      | T.Node (s_mod, [t; t_const]) when s_mod = Symbol.s_mod ->
        
        (match T.node_of_t t_const with 
          
          (* Term is a numeral *)
          | T.Leaf n when Symbol.is_numeral n ->
            
            (* Return (divisible n t) *)
            mk_divisible (Symbol.numeral_of_symbol n) t
              
          (* Keep other terms unchanged *)
          | _ -> term)
        
      (* Keep other terms unchanged *)
      | _ -> term

  in
  
  match T.node_of_t term with
    
    (* Term is (= 0 t) or (= t 0) *)
    | T.Node (s_eq, [l; r])
      when s_eq == Symbol.s_eq && l == (mk_num_of_int 0) -> 

      mod_to_divisible' r

    | T.Node (s_eq, [l; r])
      when s_eq == Symbol.s_eq && r == (mk_num_of_int 0) ->

      mod_to_divisible' l
      
  (* Keep other terms unchanged *)
  | _ -> term


(* Convert (= 0 (mod t n)) to (divisble n t) *)
let divisible_to_mod term = 

  match T.node_of_t term with
    
    (* Term is a unary function application *)
    | T.Node (s_divisble, [t]) -> 

      (* Symbol is a divisibility symbol?  *)
      (match Symbol.node_of_symbol s_divisble with

        (* Convert to (= (mod t n) 0) *)
        | `DIVISIBLE n -> mk_eq [mk_mod t (mk_num n); mk_num_of_int 0]

        (* Keep other terms unchanged *)
        | _ -> term)

    (* Keep other terms unchanged *)
    | _ -> term 



(* Infix notation for constructors *)
module Abbrev = 
struct

  let ( ?%@ ) i = mk_num_of_int i

  let ( ?/@ ) f = mk_dec_of_float f

  let ( !@ ) t = mk_not t

  let ( =>@ ) a b = mk_implies [a; b]

  let ( &@ ) a b = mk_and [a; b]

  let ( |@ ) a b = mk_or [a; b]

  let ( =@ ) a b = mk_eq [a; b]

  let ( ~@ ) a = mk_minus [a]

  let ( -@ ) a b = mk_minus [a; b]

  let ( +@ ) a b = mk_plus [a; b]

  let ( *@ ) a b = mk_times [a; b]

  let ( //@ ) a b = mk_div [a; b]

  let ( /%@ ) a b = mk_div [a; b]

  let ( <=@ ) a b = mk_leq [a; b]

  let ( <@ ) a b = mk_lt [a; b]

  let ( >=@ ) a b = mk_geq [a; b]

  let ( >@ ) a b = mk_gt [a; b]

end


(* ********************************************************************* *)
(* Folding and utility functions on terms                                *)
(* ********************************************************************* *)


(* Evaluate a term bottom-up right-to-left *)
let eval = T.eval 

(* Evaluate a term bottom-up right-to-left, given the flattened term
   as argument *)
let eval_t = T.eval_t 

(* Bottom-up right-to-left map of the term 

   Must hashcons bottom-up since term was destructed and not all terms
   are necessarily in the hashcons table. *)
let map = T.map




(* 
   Local Variables:
   compile-command: "make -C .. -k"
   tuareg-interactive-program: "./kind2.top -I ./_build -I ./_build/SExpr"
   indent-tabs-mode: nil
   End: 
*)


      
