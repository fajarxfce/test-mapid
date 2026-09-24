import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "io.github.fajarxfce.testmapid.dev"
            resValue(type = "string", name = "app_name", value = "MAPID Explorer Dev")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "io.github.fajarxfce.testmapid.staging"
            resValue(type = "string", name = "app_name", value = "MAPID Explorer Staging")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "io.github.fajarxfce.testmapid"
            resValue(type = "string", name = "app_name", value = "MAPID Explorer")
        }
    }

    buildFeatures.resValues = true
}