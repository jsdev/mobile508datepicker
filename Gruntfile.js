module.exports = function (grunt) {
	require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

    grunt.initConfig({
        // our Grunt task settings
        watch: {
        	options: {
        		nospawn: true
        	},
        	coffee: {
        		files: ['js/*coffee'],
        		tasks: ['coffee']
        	}
        },
        jshint: {
        	options: {
        		jshintrc: '.jshintrc'
        	},
        	all: {
        		'Gruntfile.js',
        		'js/*js',
        		'!js/vendor/*'
        	}
        },
        sass: {
		    dist: {
		        options: {
		            style: 'compressed'
		        },
		        expand: true,
		        cwd: './css/',
		        src: ['*.scss'],
		        dest: './css/',
		        ext: '.css'
		    },
		    dev: {
		        options: {
		            style: 'expanded',
		            debugInfo: true,
		            lineNumbers: true
		        },
		        expand: true,
		        cwd: './css/',
		        src: ['*.scss'],
		        dest: './css/',
		        ext: '.css'
		    }
		},
		coffee: {
            dist: {
                files: [{
                    expand: true,
                    cwd: './js/',
                    src: '*.coffee',
                    dest: './js/',
                    ext: '.js'
                }]
            }
        }
    });

	grunt.registerTask('build', [
		'coffee:dist',
		'sass:dist'
	]);
};
