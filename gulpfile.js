var gulp = require('gulp');

var urbitrc = require('./.urbitrc');

gulp.task('urbit-copy', function () {
  let ret = gulp.src('urbit/**/*');

  urbitrc.URBIT_PIERS.forEach(function(pier) {
    ret = ret.pipe(gulp.dest(pier));
  });

  return ret;
});

gulp.task(
  'bundle-dev',
  gulp.series(
    'urbit-copy'
  )
);

gulp.task('default', gulp.series('bundle-dev'));

gulp.task('watch', gulp.series('default', function() {
  gulp.watch('urbit/**/*', gulp.parallel('urbit-copy'));
}));
