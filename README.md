Ce package offre des outils pour nettoyer les fichiers électoraux du ministère de l'intérieur.

Pour l'installer : 
```
library(devtools)
install_github("joelgombin/LireMinInterieur")
```

Il existe également une version interactive de l'outil, grâce à `shiny` :

```{r}
library(LireMinInterieur)
lireInteractif()
```
