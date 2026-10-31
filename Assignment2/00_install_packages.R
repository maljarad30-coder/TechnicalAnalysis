# BDA400 - Assignment 2 | Mohammad Aljarad
# 00_install_packages.R
# Run this script once inside RStudio before running the analysis.

required_packages <- c("quantmod", "TTR", "zoo")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}

for (package_name in required_packages) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    stop("Package was not installed successfully: ", package_name)
  }
}

cat("All required packages are installed: ",
    paste(required_packages, collapse = ", "), "\n", sep = "")
cat("R version: ", R.version.string, "\n", sep = "")
