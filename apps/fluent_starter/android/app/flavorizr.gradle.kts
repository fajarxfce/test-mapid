import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "dev.example.fluentstarter.dev"
            resValue(type = "string", name = "app_name", value = "Fluent Starter Dev")
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "dev.example.fluentstarter.staging"
            resValue(type = "string", name = "app_name", value = "Fluent Starter Staging")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "dev.example.fluentstarter"
            resValue(type = "string", name = "app_name", value = "Fluent Starter")
        }
    }

    buildFeatures.resValues = true
}