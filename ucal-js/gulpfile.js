var gulp = require("gulp");
var print = require("gulp-print").default;

var urbitrc = require("./.urbitrc");

gulp.task("urbit-copy", function (done) {
  let ret = gulp.src("../ucal/*");

  urbitrc.URBIT_PIERS.forEach(function (pier) {
    return ret.pipe(gulp.dest(pier)).pipe(
      print(function () {
        return "Copied to: " + pier;
      })
    );
  });

  done();
});

gulp.task("bundle-dev", gulp.series("urbit-copy"));

gulp.task("default", gulp.series("bundle-dev"));

gulp.task(
  "watch",
  gulp.series("default", function () {
    gulp.watch("../ucal/*", gulp.parallel("urbit-copy"));
  })
);
