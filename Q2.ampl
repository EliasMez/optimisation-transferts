# ensemble des participants à la soirée d'anniversaire
set PARTICIPANTS;

# ensemble des cadeaux achetés à la soirée d'anniversaire
set CADEAUX;

# tableau a double entrée dont la valeur correspond au nombre de fois ou un cadeaux est acheté par un participant
param acheteur {CADEAUX, PARTICIPANTS} >=0;

# vérifie que les valeur du tableau dont les entrées sont un cadeau et son acheteur sont égales a 1 
check : forall {c in CADEAUX} sum {p in PARTICIPANTS} acheteur[c,p] = 1;

param prixCadeau {c in CADEAUX} >=0;
param prixTotalCadeaux := sum {c in CADEAUX} prixCadeau[c];

# représente le prix que chaque participant doit payer au final
param montantMoyen := prixTotalCadeaux / card(PARTICIPANTS);

# représente pour chaque participant la somme des prix des cadeaux payés par le participant
param avance {p in PARTICIPANTS} := sum {c in CADEAUX} prixCadeau[c] * acheteur[c,p];

var transfert {PARTICIPANTS, PARTICIPANTS} integer >=0, <=179;
var paye {PARTICIPANTS} integer >=0;
var recu {PARTICIPANTS} integer >=0;

# quantité intermediaire qui représente la somme reçu par chaque participant lors du transfert
subject to calcul_paye {p1 in PARTICIPANTS} :
	paye [p1] = sum {p in PARTICIPANTS} transfert[p,p1];

# quantité intermediaire qui représente la somme payé par chaque participant lors du transfert
subject to calcul_recu {p1 in PARTICIPANTS} :
        recu [p1] = sum {p in PARTICIPANTS} transfert[p1,p];

# Contraintes qui permettent de s'assurer que chaque participant paye la meme somme coutMoyen a 1 euro pres
subject to equiteMin {p in PARTICIPANTS} :
	avance [p] + paye [p] - recu [p] >= trunc(montantMoyen);

subject to equiteMax {p in PARTICIPANTS} :
	avance [p] + paye [p] - recu [p] <= trunc(montantMoyen) + 1;


# Verifie que Avare ne reçoit aucun argent lors des transitions 
subject to no_transfert_Avare {p in PARTICIPANTS} :
	recu["Avare"] = 0;	

data;
set PARTICIPANTS := Avare Beleuleu Claqueur Depensier Econome Farceur;
set CADEAUX := ordinateur tarte vase voyage plante bobRicard collier Beethoven;

param prixCadeau :=
ordinateur	1000
tarte		9
vase		25
voyage		1200
plante		10
bobRicard	5
collier		0
Beethoven	133;


param acheteur :
				Claqueur Beleuleu Avare Depensier Farceur Econome :=
ordinateur			1	 0	  0	0	  0	  0
tarte				0	 1	  0	0	  0	  0
vase				0	 0	  1	0	  0	  0
voyage				0	 0	  0	1 	  0	  0
plante				0	 1	  0	0  	  0	  0
bobRicard			0	 0	  1	0	  0	  0
collier				0	 0	  0	0  	  1	  0
Beethoven			0	 0	  0	0   	  1	  0;


option solver gurobi;
solve;
display prixCadeau;
display prixTotalCadeaux;
display montantMoyen;
display avance;
display transfert;
display paye;
display recu;


