使用方式：

1. 在代码库根目录中添加模板目录，并根据具体的服务修改内容
2. 定义 `SERVICE_NAME` 变量，（流水线中 BUILD_VERSION 变量会自动生成，可不定义）
3. 执行 `bash .cicd/package_helm.sh IMAGE-NAME` 命令，构建成功将生成应用包 `app-pack/${SERVICE_NAME}-${BUILD_VERSION}.zip`


目录结构规范
======
.cicd
    - app/                   存放构建应用包依赖的文件
        - application-tpl.yaml   应用包元数据文件模板
    - helm/                  构建helm包依赖的文件，请参考 helm 文档
        - Chart-tpl.yaml
        - values-tpl.yaml        此文件中内容请根据实际服务修改
        - templates/         此目录中内容请根据实际服务修改
            - deployment.yaml
			- service.yaml
    - package_helm.sh       执行 helm 构建的脚本文件


模板化的文件
------
名称为形式为 `aaa-tpl.bbb` 或 `aaa-template.bbb` 的会被识别为模板文件，在构建helm包之前对其文件做环境变量替换，并重命名为 `aaa.bbb`。
使用模板文件可以实现在构建过程中动态确定应用包的一些元数据（比如应用包的版本号，每次构建都会不同）。
模板的替换操作通过 envsubst 命令实现，模板文件中形式为 `${NAME}` 或 `$NAME` 的字符都会被同名的环境变量的值替代；

需要注意： 如果对应的环境变量不存会被替换为空白字符 ""。



流水线构建配置
=======
- 在流水线构建参数中设置  SERVICE_NAME 变量
- 添加 '代码检出'，'构建'，'镜像构建' 步骤， 构建出 docker 镜像
- 添加 '制作helm包' 步骤，选择前面构建出的镜像名称，构建成功后默认的输出文件为： `app-pack/${SERVICE_NAME}-${BUILD_VERSION}.zip`
- 添加 '应用包上传' 步骤，将构建出的应用包上传到应用仓库


手动执行构建
======
按约定的结构组织依赖的文件后，可以使用 package_helm.sh 执行构建。

执行的命令如下

```shell
# 前提：已经构建出了 docker 镜像，镜像名称为 IMAGE-NAME

# 定义模板中引用的环境变量
export SERVICE_NAME=demo-service
export BUILD_VERSION=v1.0

# 执行构建操作
bash .cicd/package_helm.sh  IMAGE-NAME    # IMAGE-NAME 为要打包到应用包中的镜像名称
```

构建成功后的输出文件为： `app-pack/${SERVICE_NAME}-${BUILD_VERSION}.zip`


构建过程与细节
========
请参考 `package_helm.sh` 脚本，如果默认的流程无法满足需求，可以基于 `package_helm.sh` 脚本进行修改
