#/bin/sh

VERSION=`cat version.txt`
REPO=https://github.com/k8ssandra/cass-operator.git


git clone ${REPO} src 
cd src 
echo "Checkout tag $VERSION" 
if [ "$VERSION" != "main" ] && [ ! -z "$VERSION" ] ; then git checkout tags/${VERSION} -b ${VERSION} ; fi

mkdir -p ../build

VERSION=$(git describe --tags --always --dirty) 
echo "Build version $VERSION" 
FLAGS="-X main.version=$VERSION -w -s"

GOARCH=arm64 CGO_ENABLED=0 go build -o ../build/operator.arm64 -ldflags "$FLAGS" -trimpath ./operator/cmd/manager/
GOARCH=arm GOARM=7 CGO_ENABLED=0 go build -o ../build/operator.armv7 -ldflags "$FLAGS" -trimpath ./operator/cmd/manager/
GOARCH=arm GOARM=6 CGO_ENABLED=0 go build -o ../build/operator.armv6 -ldflags "$FLAGS" -trimpath ./operator/cmd/manager/
GOARCH=s390x  CGO_ENABLED=0 go build -o ../build/operator.s390x -ldflags "$FLAGS" -trimpath ./operator/cmd/manager/
GOARCH=ppc64le  CGO_ENABLED=0 go build -o ../build/operator.ppc64le -ldflags "$FLAGS" -trimpath ./operator/cmd/manager/
GOARCH=386 GO386='softfloat' CGO_ENABLED=0 go build -o ../build/operator.x86 -ldflags "$FLAGS" -trimpath ./operator/cmd/manager/
CGO_ENABLED=0 go build -o ../build/operator.x86_64 -ldflags "$FLAGS" -trimpath ./operator/cmd/manager/
