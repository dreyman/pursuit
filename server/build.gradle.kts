plugins {
    id("java")
    application
}

group = "com.github.dreyman.pursuit"
version = "0.0.1-wip"

repositories {
    mavenCentral()
}

application {
    mainClass = "Main"
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:5.10.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")

    implementation("org.slf4j:slf4j-simple:2.0.16")
    implementation("io.javalin:javalin:6.4.0")
    implementation("com.google.code.gson:gson:2.12.1")
    implementation("org.xerial:sqlite-jdbc:3.49.1.0")
    implementation("com.drewnoakes:metadata-extractor:2.19.0")
}

tasks.test {
    useJUnitPlatform()
}