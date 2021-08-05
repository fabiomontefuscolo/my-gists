# New Openfire Plugin

## Install requirements

```sh
$ sudo pacman -S \
	intellij-idea-community-edition \
	jre8-openjdk \
	maven
```

## Environment

```sh
$ export WORKSPACE_FOLDER=/home/fabio/Work/avantech
```

## Openfire

### Getting the code

```sh
$ git clone --depth=1 https://github.com/igniterealtime/Openfire.git openfire
```

### Building the project

```sh
$ cd openfire
$ mvn verify
$ cd ..
```

## A dumb plugin

### Creating folders
```sh
$ mkdir -p example-plugin/src/web
$ mkdir -p example-plugin/src/java/br/com/example
```

### Creating the pom.xml
```sh
$ cat > example-plugin/pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <artifactId>plugins</artifactId>
        <groupId>org.igniterealtime.openfire</groupId>
        <version>4.3.0-beta</version>
    </parent>
    <groupId>org.igniterealtime.openfire.plugins</groupId>

    <artifactId>exampleplugin</artifactId>
    <version>0.1</version>
    <name>Example Plugin</name>
    <description>A start point to create a new plugin</description>

    <organization>
        <name>Example Organization</name>
        <url>https://example-url.com.br/</url>
    </organization>

    <developers>
        <developer>
            <id>exampleuserid</id>
            <name>Example Author</name>
            <email>example@email.com</email>
            <organization>Example Organization</organization>
        </developer>
    </developers>

    <build>
        <sourceDirectory>src/java</sourceDirectory>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <!-- FIXME: This temporarily overrides the provided plugin, to set appendAssemblyId and attach to true.
                     This change should be pushed down to the parent project, after the development to distribute plugins via Maven has settled. -->
                <artifactId>maven-assembly-plugin</artifactId>
                <version>2.6</version>
                <dependencies>
                    <dependency>
                        <groupId>org.igniterealtime.openfire.plugins</groupId>
                        <artifactId>openfire-plugin-assembly-descriptor</artifactId>
                        <version>${openfire.version}</version>
                    </dependency>
                </dependencies>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                        <configuration>
                            <appendAssemblyId>true</appendAssemblyId>
                            <finalName>${plugin.name}</finalName>
                            <attach>true</attach>
                            <!-- This is where we use our shared assembly descriptor -->
                            <descriptorRefs>
                                <descriptorRef>openfire-plugin-assembly</descriptorRef>
                            </descriptorRefs>
                        </configuration>
                    </execution>
                </executions>
                <!-- End of override -->
            </plugin>
            <!-- Compiles the Openfire Admin Console JSP pages. -->
            <plugin>
                <groupId>org.eclipse.jetty</groupId>
                <artifactId>jetty-jspc-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

    <dependencies>
    </dependencies>

    <distributionManagement>
        <!-- Repository in which we deploy this project, when desired. -->
        <repository>
            <id>igniterealtime</id>
            <name>Ignite Realtime Repository</name>
            <url>https://www.igniterealtime.org/archiva/repository/maven/</url>
        </repository>
    </distributionManagement>

    <repositories>
        <!-- Where we obtain dependencies. -->
        <repository>
            <id>igniterealtime</id>
            <name>Ignite Realtime Repository</name>
            <url>https://igniterealtime.org/archiva/repository/maven/</url>
        </repository>
    </repositories>

    <pluginRepositories>
        <!-- Typically used to retrieve Maven plugins used by this project from. This
             apparently is also used to obtain the dependencies _used by_ plugins
             (eg: openfire-plugin-assembly-descriptor) -->
        <pluginRepository>
            <id>igniterealtime</id>
            <name>Ignite Realtime Repository</name>
            <url>https://igniterealtime.org/archiva/repository/maven/</url>
        </pluginRepository>
    </pluginRepositories>
</project>
EOF
```

### Creating the plugin.xml

```sh
$ cat > example-plugin/plugin.xml <<'EOF' 
<?xml version="1.0" encoding="UTF-8"?>
<plugin>
    <class>br.com.example.ExamplePlugin</class>
    <name>Example Plugin</name>
    <description>A start point to create a new plugin</description>
    <author>Example author</author>
    <version>${project.version}</version>
    <date>1/2/2019</date>
    <minServerVersion>4.3.2</minServerVersion>
</plugin>
EOF
```

### Creating the plugin main class

```sh
$ cat > example-plugin/src/java/br/com/example/ExamplePlugin.java <<'EOF' 
package br.com.example;

import java.io.File;
import java.security.Security;
import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
  * This class initialize the ExamplePlugin
  */
public class ExamplePlugin implements Plugin
{
    private static final Logger Log = LoggerFactory.getLogger( ExamplePlugin.class );

    @Override
    public void initializePlugin( PluginManager manager, File pluginDirectory )
    {
        Log.info("Initializing Example Plugin");
    }

    @Override
    public void destroyPlugin()
    {
        Log.info("Destroying Example Plugin");
    }
}
EOF
```

### Verify if dumb plugin compile

```sh
$ cd example-plugin
$ mvn verify 
```

## Development

### Setting up IDEA

1. Execute idea
2. Click on **Import Project**
3. Select the Openfire directory
4. Select **Maven** option and clik on **Next**
5. Click on **Next**
6. Click on **Next**
7. Click on **Next**
8. Check if JRE is select and click on **Next**
9. Give **Project name** the value **openfire** and click on **Finish**
10. Click on **File** > **Project Structure**
11. Got to modules section
12. Click on **+** sign in the top of second column
13. Click on **Import module**
14. Select **example-plugin**
15. Select **Maven** option and clik on **Next**
16. Click  on **Next**
17. Click  on **Next**
18. Click on **Finish**
19. Click on **Ok**
20. Click on **Run** > **Edit Configurations**
21. Click on **+** sign and select **Remote**
22. Change the Name from **Unamed** to **Attach on Openfire**
23. Copy the content of **Command line arguments for remote JVM**, it will be something like `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005`

### Running Openfire

The only I could have breakpoints during development was adding manually the options `-DpluginDirs`, `-Dexample-plugin.classes`, `-Dexample-plugin.webRoot`. Even passing these options, depending the type of change made in source code, it will be necessary to restart Openfire.

```sh
$ cd openfire
$ java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
	-Dlog4j.configurationFile=${WORKSPACE_FOLDER}/openfire/distribution/target/distribution-base/lib/log4j2.xml \
	-server \
	-DopenfireHome="${WORKSPACE_FOLDER}/openfire/distribution/target/distribution-base" \
	-DpluginDirs="${WORKSPACE_FOLDER}/example-plugin" \
	-Dexample-plugin.classes="target/classes" \
	-Dexample-plugin.webRoot="src/web" \
	-Dopenfire.lib.dir="${WORKSPACE_FOLDER}/openfire/distribution/target/distribution-base/lib" \
	-classpath "${WORKSPACE_FOLDER}/openfire/distribution/target/distribution-base/lib/startup.jar" \
	-jar "${WORKSPACE_FOLDER}/openfire/distribution/target/distribution-base/lib/startup.jar"
```

You should see an output like 

```
Listening for transport dt_socket at address: 5005
Openfire 4.4.0 Alpha [Feb 21, 2019 5:05:11 PM]
Admin console listening at:
  http://localhost:9090
  https://localhost:9091
Successfully loaded plugin 'admin'.
Plugin 'example-plugin' is running in development mode.
Successfully loaded plugin 'example-plugin'.
Successfully loaded plugin 'search'.
Finished processing all plugins.
```

 That is it. Have fun