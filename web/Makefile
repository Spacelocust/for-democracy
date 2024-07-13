## All commands available in the Makefile (dev container only)

##@ Starting/stopping the project

up:
	apt-get update
	apt-get install -y docker.io
	flutter pub get

##@ Dart

dart-build-runner: ## Run build_runner
	dart run build_runner build --delete-conflicting-outputs
