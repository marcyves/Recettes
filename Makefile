.PHONY: all clean

all: recettes.pdf

cookbook-body.tex:
	@echo "Generating cookbook-body.tex..."
	@rm -f cookbook-body.tex
	@current_dir="" ; \
	find . -type f -name "*.cook" | sort | while read -r file; do \
		echo "Processing $$file" ; \
		dir_name=$$(basename "$$(dirname "$$file")") ; \
		if [ "$$dir_name" != "." ] && [ "$$dir_name" != "$$current_dir" ]; then \
			echo "\\part{$$dir_name}" >> cookbook-body.tex ; \
			current_dir="$$dir_name" ; \
		fi ; \
		title=$$(basename "$$file" .cook) ; \
		cook recipe "$$file" -f latex -o tmp_recipe.tex ; \
		awk -v title="$$title" 'BEGIN { print "\\chapter*{" title "}"; print "\\addcontentsline{toc}{chapter}{" title "}"; print "\\markboth{" title "}{" title "}" } /% BEGIN_TITLE/ { skip_title = 1; next } /% END_TITLE/ { skip_title = 0; next } /% BEGIN_RECIPE_CONTENT/ { in_body = 1; next } /% END_RECIPE_CONTENT/ { in_body = 0 } in_body && !skip_title { gsub(/\\section\*{Ingredients}/, "\\section*{Ingrédients}"); gsub(/\\section\*{Cookware}/, "\\section*{Ustensiles}"); gsub(/\\section\*{Instructions}/, "\\section*{Préparation}"); gsub(/Servings:/, "Nombre de personnes :"); gsub(/Prep time:/, "Préparation :"); gsub(/Cook time:/, "Cuisson :"); print }' tmp_recipe.tex >> cookbook-body.tex ; \
	done
	@rm -f tmp_recipe.tex

recettes.pdf: cookbook-body.tex recettes.tex
	xelatex recettes.tex
	xelatex recettes.tex

clean:
	rm -f cookbook-body.tex recettes.pdf recettes.aux recettes.log recettes.out recettes.toc tmp_recipe.tex
