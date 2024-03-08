all: clean build

clean:
	rm -f .terraform.lock.hcl
	rm -rf .terraform
	rm -rf ./lambda/*.zip
	rm -f ./test/go.mod
	rm -f ./test/go.sum
	rm -f tf.json
	rm -f tf.plan
	rm -f *.tfvars
	rm -rf builds/
	rm -rf examples/*/.terraform
	rm -rf examples/*/.terraform.lock.hcl
	rm -rf examples/*/builds/
	rm -f examples/*/*.tfvars
	rm -rf examples/*/tmp/
	rm -rf tmp/
	rm -rf *.zip
	cd boomi-license-validation && $(MAKE) clean

build:
	cd boomi-license-validation && $(MAKE) all