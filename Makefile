build:
	docker build -t rstudio .

run:
	docker run -ti -p 8787:8787 --privileged -e PASSWORD=blablabla --rm rstudio /init	
