DOCKER_TAG := latest
DOCKER_IMG := m1dnight/occupancy

.PHONY: build

build:
	docker build -t $(DOCKER_IMG):$(DOCKER_TAG) .

rebuild:
	docker build --no-cache -t $(DOCKER_IMG):$(DOCKER_TAG) .

push: 
	docker push $(DOCKER_IMG):$(DOCKER_TAG)
