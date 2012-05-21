abstract ParseEngAbs = 
  Tense,
  Cat,
  Noun - [PPartNP],
  Adjective,
  Numeral,
  Symbol [PN, Symb, String, MkSymb, SymbPN],
  Conjunction,
  Verb - [SlashV2V, PassV2, UseCopula],
  Adverb,
  Phrase,
  Sentence,
  Relative,
  Idiom [NP, VP, Cl, ProgrVP, ExistNP],
  Extra [NP, Quant, VPSlash, VP, GenNP, PassVPSlash,
         Temp, Pol, Conj, VPS, ListVPS, S, MkVPS, BaseVPS, ConsVPS, ConjVPS, PredVPS,
         VPI, ListVPI, VV, MkVPI, BaseVPI, ConsVPI, ConjVPI, ComplVPIVV],
  DictEngAbs ** {

fun CompoundCN : Num -> N -> CN -> CN ;
    DashCN : N -> N -> N ;
    GerundN : V -> N ;
    GerundAP : V -> AP ;
    PastPartAP : V2 -> AP ;
    myself_NP : NP ;
    yourselfSg_NP : NP ;
    himself_NP : NP ;
    herself_NP : NP ;
    itself_NP : NP ;
    ourself_NP : NP ;
    yourselfPl_NP : NP ;
    themself_NP : NP ;
    themselves_NP : NP ;
    OrdCompar : A -> Ord ;

    PositAdVAdj : A -> AdV ;

    UseQuantPN : Quant -> PN -> NP;

    SlashV2V : V2V -> Pol -> VP -> VPSlash ;

    ComplPredVP : NP -> VP -> Cl ;
    
    that_RP, no_RP : RP ;
    
    CompS : S -> Comp ;
    CompVP : VP -> Comp ;

	PassVS : VS -> VP -> VP ;
	PPartNP : NP -> VPSlash -> NP ;
}
