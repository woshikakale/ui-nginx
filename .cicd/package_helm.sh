#!/bin/bash

set -e
cd $(dirname $0)/../

imageName=$1

if [ $SERVICE_NAME == '' ]; then
   echo "$SERVICE_NAME not defined"
   exit -1
fi

if [ $BUILD_VERSION == '' ]; then
   echo "$BUILD_VERSION not defined"
   exit -1
fi

if [ $imageName == '' ]; then
   echo "usage: ./package_helm.sh imageName"
   exit -1
fi

function envsubst_dir(){
    for file in $(ls $1); do
        if [ -d "$1/$file" ]; then
            mkdir -p $2/$file
            envsubst_dir "$1/$file" "$2/$file"
        elif [[ $file == *-template.* ]]; then
            echo "subst: $1/$file > $2/${file/-template/}"
            envsubst < "$1/$file" > "$2/${file/-template/}"
        elif [[ $file == *-tpl.* ]]; then
            echo "subst: $1/$file > $2/${file/-tpl/}"
            envsubst < "$1/$file" > "$2/${file/-tpl/}"
        else
            echo "copy : $1/$file > $2/$file"
            cp "$1/$file" "$2/$file"
        fi
    done
}

rm -rf helm-pack app-pack
mkdir -p helm-pack/$SERVICE_NAME app-pack/$SERVICE_NAME

echo ""
echo ">> build helm package..."
envsubst_dir .cicd/helm helm-pack/$SERVICE_NAME

cd helm-pack
echo ""
echo ">> helm package ${SERVICE_NAME} --save=false"
helm package ${SERVICE_NAME} --save=false
cd ..
echo ">> helm package: `ls helm-pack/*.tgz`"

echo ""
echo ">> assemble file for app package..."
cp -f helm-pack/*.tgz app-pack/$SERVICE_NAME
envsubst_dir .cicd/app app-pack/$SERVICE_NAME

echo ""
echo ">> export image: ${SERVICE_NAME}:${BUILD_VERSION}"
mkdir -p app-pack/$SERVICE_NAME/images

if [ "$imageName" != "${SERVICE_NAME}:${BUILD_VERSION}" ]; then
  docker tag $imageName ${SERVICE_NAME}:${BUILD_VERSION}
fi
docker save -o app-pack/$SERVICE_NAME/images/${SERVICE_NAME}-${BUILD_VERSION}.tar ${SERVICE_NAME}:${BUILD_VERSION}

echo ""
echo ">> app package..."
cd app-pack
mv $SERVICE_NAME ${SERVICE_NAME}-${BUILD_VERSION}
zip -r ${SERVICE_NAME}-${BUILD_VERSION}.zip ${SERVICE_NAME}-${BUILD_VERSION}
cd ..
echo ">> app package: `ls app-pack/*.zip`"