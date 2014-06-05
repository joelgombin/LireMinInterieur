# compilation en bytecode de la fonction
enableJIT(3)


#' Fonction pour transformer les fichiers du ministère de l'intérieur en data.frame utilisable
#' 
#' La fonction \code{lire} est utile pour transformer les fichiers de résultats électoraux diffusés par le ministère de l'Intérieur français, lorsque l'offre électorale n'est pas homogène sur l'ensemble du territoire (législatives, européennes, cantonales, régionales...). Pour ce faire, les résultats sont agrégés en fonction des étiquettes attribuées par le ministère de l'intérieur. 
#' 
#'  @param X un data.frame brut. Généralement importé depuis un CSV.
#'  @param keep vecteur indiquant le numéro (ou le nom) des colonnes à conserver telles quelles (habituellement Inscrits, Exprimés, Blancs, Nuls, etc.). Il doit impérativement y avoir les Inscrits et les Exprimés.
#'  @param col vecteur indiquant le numéro des colonnes contenant les étiquettes à partir desquelles les résultats sont agrégés. Généralement, leur espacement est régulier, donc peut s'écrire sous la forme de, e.g., \code{seq(10, 100, 10)}.
#'  @param keep.names le nom à donner aux colonnes conservées en l'état (paramètre \code{keep}). Par défaut, le nom de ces colonnes dans le \code{data.frame X}. Il est nécessaire qu'il y ait une colonne intitulée "Inscrits" et une colonne intitulée "Exprimés". 
#'  @param gap décalage entre les colonnes avec les étiquettes et les colonnes avec le nombre de voix. Par défaut, 3.
#'  
#'  @return un \code{data.frame} avec les colonnes conservées ainsi que, pour chaque nuance politique, une colonne avec le total des voix, une colonne avec le score rapporté aux inscrits, une colonne avec le score rapporté aux exprimés. Enfin, une colonne indique le nombre de candidats (ou de listes) qu'il y avait dans la circonscription territoriale.
#'  @export
#'  @import compiler
#'  @examples
#'  data(Eur2014Dpts)
#'  names(Eur2014Dpts)
#'  res <- lire(Eur2014Dpts, keep = c(2,4,5,7,9,12,15), col=c(seq(19,229,7)), keep.names=c("CodeDpt", "Inscrits", "Asbtentions","Votants", "Blancs", "Nuls", "Exprimés"))

lire <- function(X, keep, col, keep.names = names(res), gap=3) {
  # on s'assure qu'il n'y a pas de factors qui traînent mais que des characters
  X[,sapply(X, is.factor)] <- as.character(X[,sapply(X, is.factor)])  
  # on crée un df dans lequel on va stocker les résultats
  res <- X[,keep]
  names(res) <- keep.names
  
  # on récupère l'ensemble des nunances possibles
  nuances <- unique(unlist(X[,col]))[!seq_along(unique(unlist(X[,col]))) %in% match("",unique(unlist(X[,col])))]
  
  etiquettes <- X[,col]
  valeurs <- X[,col + gap]
  valeurs$index <- 1:nrow(valeurs)
  
  increment <- function(x, n, etiquettes) ifelse(n %in% etiquettes[x["index"],], sum(x[match(n, etiquettes[x["index"],])]), 0)
  
  
  res[,nuances] <- sapply(nuances, function(n) {
    apply(valeurs, 1, function(x) increment(x, n, etiquettes))
  })
  res$NbCand <- apply(etiquettes, 1, function(x) sum(!(x %in% "")))
  
  
  res[,paste(nuances, ".ins", sep="")] <- res[,nuances]/res[,"Inscrits"]*100
  res[,paste(nuances, ".exp", sep="")] <- res[,nuances]/res[,"Exprimés"]*100
  return(res)
}



#' Résultats des élections européennes de 2014, par département
#' 
#' @details Un jeu de données contenant les résultats des élections européennes de 2014, par département. Les données ont été téléchargées sur \url{http://www.data.gouv.fr/fr/dataset/elections-europeennes-2014-resulta-1}, puis la feuille consacrée aux départements a été sauvegardée en csv (en enlevant simplement les deux premières lignes, pour que les titres de colonnes soient sur la première ligne). Elle a ensuite été importée dans R avec le code suivant : \code{Eur2014Dpts <- read.csv("./Eur2014Dpts.csv", header=TRUE, sep=";", stringsAsFactor=FALSE)}.
#' 
#' @docType data
#' @keywords dataset
#' @format un jeu de données de 107 lignes et 234 variables
#' @name Eur2014Dpts
#' @source \url{http://www.data.gouv.fr/fr/dataset/elections-europeennes-2014-resulta-1}
NULL 
