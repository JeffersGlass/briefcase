=============================
Project configuration options
=============================

Briefcase is a `PEP518 <https://peps.python.org/pep-0518/>`__-compliant build
tool. It uses a ``pyproject.toml`` file, in the root directory of your project,
to provide build instructions for the packaged file.

If you have an application called "My App", with source code in the ``src/myapp``
directory, the simplest possible ``pyproject.toml`` Briefcase configuration
file would be::

    [tool.briefcase]
    project_name = "My Project"
    bundle = "com.example"
    version = "0.1"

    [tool.briefcase.app.myapp]
    formal_name = "My App"
    description = "My first Briefcase App"
    sources = ['src/myapp']

The configuration sections are tool specific, and start with the prefix
``tool.briefcase``.

The location of the ``pyproject.toml`` file is treated as the root of the
project definition. Briefcase should be invoked in a directory that contains a
``pyproject.toml`` file, and all relative file path references contained in the
``pyproject.toml`` file will be interpreted relative to the directory that
contains the ``pyproject.toml`` file.

Changes to these options will not take effect until you run the appropriate
``briefcase`` command:

* For :attr:`sources`, run ``briefcase update``, or pass the ``-u`` option to
  ``briefcase build`` or ``briefcase run``.
* For :attr:`requires`, run ``briefcase update -r``, or pass the ``-r``
  option to ``briefcase build`` or ``briefcase run``.
* For :attr:`icon` (including an :attr:`document_type_id.icon`
  definition in a document type), run ``briefcase update --update-resources``, or pass
  the ``--update-resources`` option to ``briefcase build`` or ``briefcase run``.
* For any other options, you'll need to re-run ``briefcase create``.


Configuration sections
======================

A project that is packaged by Briefcase can declare multiple *applications*.
Each application is a distributable product of the build process. A simple
project will only have a single application. However, a complex project may
contain multiple applications with shared code.

Each setting can be specified:

* At the level of an output format (e.g., settings specific to building macOS
  DMGs);
* At the level of an platform for an app (e.g., macOS specific settings);
* At the level of an individual app; or
* Globally, for all applications in the project.

When building an application in a particular output format, Briefcase will look
for settings in the same order. For example, if you're building a macOS DMG for
an application called ``myapp``, Briefcase will look for macOS DMG settings for
``myapp``, then for macOS settings for ``myapp``, then for ``myapp`` settings,
then for project-level settings.

``[tool.briefcase]``
--------------------

The base ``[tool.briefcase]`` section declares settings that project specific,
or are are common to all applications in this repository.

``[tool.briefcase.app.<app name>]``
-----------------------------------

Configuration options for a specific application.

``<app name>`` must adhere to a valid Python distribution name as specified in
`PEP508 <https://peps.python.org/pep-0508/#names>`__. The app name must also
*not* be a reserved word in Python, Java or JavaScript (i.e., app names like
``switch`` or ``pass`` would not be valid); and it may not include any of the
`filenames prohibited by Windows
<https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file#naming-conventions>`__
(i.e., ``CON``, ``PRN``, or ``LPT1``).

``[tool.briefcase.app.<app name>.<platform>]``
----------------------------------------------

Configuration options for an application that are platform specific. The
platform must match a name for a platform supported by Briefcase (e.g.,
``macOS`` or ``windows``). A list of the platforms supported by Briefcase can
be obtained by running ``briefcase -h``, and inspecting the help for the
``platform`` option

``[tool.briefcase.app.<app name>.<platform>.<output format>]``
--------------------------------------------------------------

Configuration options that are specific to a particular output format. For
example, macOS applications can be generated in ``app`` or ``dmg`` format.

This section can contain additional layers. for example, an app targeting the
Linux ``system`` backend can define a ``tool.briefcase.app.<app
name>.linux.system.ubuntu.jammy`` section to provide configurations specific to
Ubuntu 22.04 "Jammy" deployments. See the documentation for each backend for
more details.

Project configuration
=====================

Required values
---------------

.. attribute:: bundle

A reverse-domain name that can be used to identify resources for the
application e.g., ``com.example``. The bundle identifier will be combined with
the app name to produce a unique application identifier - e.g., if the bundle
identifier is ``com.example`` and the app name is ``myapp``, the application
will be identified as ``com.example.myapp``.

.. attribute:: project_name

The project is the collection of all applications that are described by the
briefcase configuration. For projects with a single app, this may be the same
as the formal name of the solitary packaged app.

.. attribute:: version

A `PEP440 <https://peps.python.org/pep-0440/>`__ compliant version string.

Examples of valid version strings:

* ``1.0``
* ``1.2.3``
* ``1.2.3.dev4`` - A development release
* ``1.2.3a5`` - An alpha pre-release
* ``1.2.3b6`` - A Beta pre-release
* ``1.2.3rc7`` - A release candidate
* ``1.2.3.post8`` - A post-release

Optional values
---------------

.. attribute:: author

The person or organization responsible for the project.

.. attribute:: author_email

The contact email address for the person or organization responsible for the
project.

.. attribute:: url

A URL where more details about the project can be found.

Application configuration
=========================

Required
--------

.. attribute:: description

A short, one-line description of the purpose of the application.

.. attribute:: sources

A list of paths, relative to the ``pyproject.toml`` file, where source code for
the application can be found. The contents of any named files or folders will be
copied into the application bundle. Parent directories in any named path will
not be included. For example, if you specify ``src/myapp`` as a source, the
contents of the ``myapp`` folder will be copied into the application bundle; the
``src`` directory will not be reproduced.

Unlike most other keys in a configuration file, :attr:`sources` is a *cumulative*
setting. If an application defines sources at the global level, application
level, *and* platform level, the final set of sources will be the
*concatenation* of sources from all levels, starting from least to most
specific.

The only time ``sources`` is *not* required is if you are is :doc:`packaging an external
application </how-to/external-apps>`. If you are packaging an external application,
``external_package_path`` must be defined, and ``sources`` *must not* be defined.

Optional values
---------------

.. attribute:: accent_color

A hexadecimal RGB color value (e.g., ``#D81B60``) for a subtle secondary color
to be used throughout an application to call attention to key elements. This
setting is only used if the platform allows color modification, otherwise it
is ignored.

.. attribute:: build

A build identifier. An integer, used in addition to the version specifier,
to identify a specific compiled version of an application.

.. attribute:: cleanup_paths

A list of strings describing paths that will be *removed* from the project after
the installation of the support package and app code. The paths provided will be
interpreted relative to the platform-specific build folder generated for the app
(e.g., the ``build/my-app/macOS/app`` folder in the case of a macOS app).

Paths can be:
 * An explicit reference to a single file
 * An explicit reference to a single directory
 * Any file system glob accepted by ``pathlib.glob`` (See `the Python
   documentation for details
   <https://docs.python.org/3/library/pathlib.html#pathlib.Path.glob>`__)

Paths are treated as format strings prior to glob expansion. You can use Python
string formatting to include references to configuration properties of the app
(e.g., ``app.formal_name``, ``app.version``, etc).

For example, the following :attr:`cleanup_paths` specification::

    cleanup_paths = [
        "path/to/unneeded_file.txt",
        "path/to/unneeded_directory",
        "path/**/*.exe",
        "{app.formal_name}/content/extra.doc"
    ]

on an app with a formal name of "My App" would remove:

1. The file ``path/to/unneeded_file.txt``
2. The directory ``path/to/unneeded_directory``
3. Any ``.exe`` file in ``path`` or its subdirectories.
4. The file ``My App/content/extra.doc``.

.. attribute:: console_app

A Boolean describing if the app is a console app, or a GUI app. Defaults to ``False``
(producing a GUI app). This setting has no effect on platforms that do not support a
console mode (e.g., web or mobile platforms). On platforms that do support console apps,
the resulting app will write output directly to ``stdout``/``stderr`` (rather than
writing to a system log), creating a terminal window to display this output (if the
platform allows).

.. attribute:: exit_regex

A regular expression that will be executed against the console output generated
by an application. If/when the regular expression find match, the application
will be terminated; the line matching the regular expression will *not* be
output to the console. Used by Briefcase to monitor test suites; however, the
filter will also be honored on normal ``run`` invocations.

The regular expression should capture a single group named ``returncode``,
capturing the integer exit status that should be reported for the process. The
default value for this regular expression is ``^>>>>>>>>>> EXIT
(?P<returncode>.*) <<<<<<<<<<$`` The regex will be compiled with the
``re.MULTILINE`` flag enabled.

.. attribute:: external_package_path

.. admonition:: Only for external apps

    This setting is only required if you're using Briefcase to :doc:`package an external
    application </how-to/external-apps>`. It is not required if you are using Briefcase
    for the entire app creation process.

The value of ``external_package_path`` defines the path to the root of a folder that
will be packaged as an application. The contents of ``external_package_path`` is what
will be shipped to the end user as the installed app.

If ``external_package_path`` is defined, ``sources`` must *not* be defined.

.. attribute:: external_package_executable_path

.. admonition:: Only for external apps

    This setting is only allowed if you're using Briefcase to :doc:`package an external
    application </how-to/external-apps>`. It is not allowed if you are using Briefcase
    for the entire app creation process.

The path, relative to :attr:`external_package_path`, to the binary
that will be executed as part of the installed app. This is used
to establish the path to the shortcut that should be installed.

This setting is only used on Windows.

.. attribute:: formal_name

The application name as it should be displayed to humans. This name may contain
capitalization and punctuation. If it is not specified, the :attr:`name` will be
used.

.. attribute:: icon

A path, relative to the directory where the ``pyproject.toml`` file is located,
to an image to use as the icon for the application. The path should *exclude*
the extension; Briefcase will append a platform appropriate extension when
configuring the application. For example, an icon specification of ``icon =
"resources/icon"`` will use ``resources/icon.icns`` on macOS, and
``resources/icon.ico`` on Windows.

Some platforms require multiple icons, at different sizes; these will be
handled by appending the required size to the provided icon name. For example,
iOS requires multiple icon sizes (ranging from 20px to 1024px); Briefcase will
look for ``resources/icon-20.png``, ``resources/icon-1024.png``, and so on. The
sizes that are required are determined by the platform template.

.. attribute:: installer_icon

A path, relative to the directory where the ``pyproject.toml`` file is located,
to an image to use as the icon for the installer. As with :attr:`icon`, the
path should *exclude* the extension, and a platform-appropriate extension will
be appended when the application is built.

.. attribute:: installer_background

A path, relative to the directory where the ``pyproject.toml`` file is located,
to an image to use as the background for the installer. The path should
*exclude* the extension, and a platform-appropriate extension will be appended
when the application is built.

.. attribute:: long_description

A longer description of the purpose of the application. This description can be
multiple paragraphs, if necessary. The long description *must not* be a copy of
the :attr:`description`, or include the :attr:`description` as the first line of the
:attr:`long_description`

.. py:attribute:: min_os_version

A string describing the minimum OS version that the generated app will support. This
value is only used on platforms that have a clear mechanism for specifying OS version
compatibility; on the platforms where it *is* used, the interpretation of the value is
platform specific. Refer to individual platform guides for details on how the provided
value is interpreted.

.. attribute:: requirement_installer_args

A list of strings of arguments to pass to the requirement installer when building the
app.

Strings will be automatically transformed to absolute paths if they appear to be
relative paths (i.e., starting with ``./`` or ``../``) and resolve to an existing path
relative to the app's configuration file. This is done to support build targets where
the requirement installer command does not run with the same working directory as the
configuration file.

If you encounter a false-positive and need to prevent this transformation,
you may do so by using a single string for the argument name and the value.
Arguments starting with ``-`` will never be transformed, even if they happen to resolve
to an existing path relative to the configuration file.

The following examples will have the relative path transformed to an absolute one when
Briefcase runs the requirement installation command if the path ``wheels`` exists
relative to the configuration file:

.. code-block:: TOML

    requirement_installer_args = ["--find-links", "./wheels"]

    requirement_installer_args = ["-f", "../wheels"]

On the other hand, the next two examples avoid it because the string starts with ``-``,
does not start with a relative path indication (``./`` or ``../``), or do not resolve
to an existing path:

.. code-block:: TOML

    requirement_installer_args = ["-f./wheels"]

    requirement_installer_args = ["--find-links=./wheels"]

    requirement_installer_args = ["-f", "wheels"]

    requirement_installer_args = ["-f", "./this/path/does/not/exist"]

.. admonition:: Supported arguments

    The arguments supported in :attr:`requirement_installer_args` depend on the requirement
    installer backend.

    The only currently supported requirement installer is ``pip``. As such, the list
    should only contain valid
    arguments to the ``pip install`` command.

    Briefcase does not validate the inputs to this configuration, and will only report
    errors directly indicated by the requirement installer backend.

.. attribute:: primary_color

A hexadecimal RGB color value (e.g., ``#008577``) to use as the primary color
for the application. This setting is only used if the platform allows color
modification, otherwise it is ignored.

.. attribute:: primary_color_dark

A hexadecimal RGB color value (e.g., ``#008577``) used alongside the primary
color. This setting is only used if the platform allows color modification,
otherwise it is ignored.


.. _configuration-requires-key:

.. attribute:: requires

A list of packages that must be packaged with this application.

Unlike most other keys in a configuration file, :attr:`requires` is a *cumulative*
setting. If an application defines requirements at the global level,
application level, *and* platform level, the final set of requirements will be
the *concatenation* of requirements from all levels, starting from least to
most specific.

Any PEP 508 version specifier is legal. For example:

* Bare package name::

    requires = ["pillow"]

* Package name with version specifier::

    requires = ["pillow==9.1.0"]

* Install from source using the ``--no-binary`` entry::

    requires = [
        "pillow==9.1.0",
        "--no-binary", "pillow",
    ]

* Git repository::

    requires=["git+https://github.com/beeware/briefcase.git"]

* Local directory::

    requires=["mysrc/myapp"]

* Local wheel file::

    requires=["fullpath/wheelfile.whl"]

.. attribute:: revision

An identifier used to differentiate specific builds of the same version of an
app. Defaults to ``1`` if not provided.

.. attribute:: splash_background_color

A hexadecimal RGB color value (e.g., ``#6495ED``) to use as the background
color for splash screens.

If the platform output format does not use a splash screen, this setting is
ignored.

.. attribute:: stub_binary

A file path or URL pointing at a pre-compiled binary (or a zip/tarball of a binary) that
can be used as an entry point for a bundled application.

If this setting is not provided, and a stub binary is required by the platform,
Briefcase will use the default stub binary for the platform.

.. attribute:: stub_binary_revision

The specific revision of the stub binary that should be used. By default, Briefcase will
use the stub binary revision nominated by the application template. If you specify a
stub binary revision, that will override the revision nominated by the application
template.

If you specify an explicit stub binary (using the :attr:`stub_binary` setting), this
argument is ignored.

.. attribute:: support_package

A file path or URL pointing at a tarball containing a Python support package.
(i.e., a precompiled, embeddable Python interpreter for the platform)

If this setting is not provided, Briefcase will use the default support
package for the platform.

.. attribute:: support_revision

The specific revision of a support package that should be used. By default,
Briefcase will use the support package revision nominated by the application
template. If you specify a support revision, that will override the revision
nominated by the application template.

If you specify an explicit support package (either as a URL or a file path),
this argument is ignored.

.. attribute:: supported

Indicates that the platform is not supported. For example, if you know that
the app cannot be deployed to Android for some reason, you can explicitly
prevent deployment by setting ``supported=False`` in the Android section of
the app configuration file.

If :attr:`supported` is set to ``false``, the create command will fail, advising
the user of the limitation.

.. attribute:: template

A file path or URL pointing at a `cookiecutter
<https://github.com/cookiecutter/cookiecutter>`__ template for the output
format.

If this setting is not provided, Briefcase will use a default template for
the output format and Python version.

.. attribute:: template_branch

The branch of the project template to use when generating the app. If the
template is a local file, this attribute will be ignored. If not specified,
Briefcase will use a branch matching the version of Briefcase that is being
used (i.e., if you're using Briefcase 0.3.9, Briefcase will use the
``v0.3.9`` template branch when generating the app). If you're using a
development version of Briefcase, Briefcase will use the ``main`` branch of the
template.

.. attribute:: test_requires

A list of packages that are required for the test suite to run.

Unlike most other keys in a configuration file, :attr:`test_requires` is a
*cumulative* setting. If an application defines requirements at the global
level, application level, *and* platform level, the final set of requirements
will be the *concatenation* of requirements from all levels, starting from least
to most specific.

See :ref:`requires <configuration-requires-key>` for examples.

.. attribute:: test_sources

A list of paths, relative to the ``pyproject.toml`` file, where test code for
the application can be found. The contents of any named files or folders will be
copied into the application bundle. Parent directories in any named path will
not be included. For example, if you specify ``src/myapp`` as a source, the
contents of the ``myapp`` folder will be copied into the application bundle; the
``src`` directory will not be reproduced.

As with :attr:`sources`, :attr:`test_sources` is a *cumulative* setting. If an
application defines sources at the global level, application level, *and*
platform level, the final set of sources will be the *concatenation* of test
sources from all levels, starting from least to most specific.

Permissions
===========

Applications may also need to declare the permissions they require. Permissions are
specified as sub-attributes of a ``permission`` property, defined at the level of an
project, app, or platform. Permission declarations are *cumulative*; if an application
defines permissions at the global level, application level, *and* platform level, the
final set of permissions will be the *merged* set of all permissions from all levels,
starting from least to most specific, with the most specific taking priority.

Briefcase maintains a set of cross-platform permissions:

.. attribute:: permission.camera

Permission to access the camera to take photos or video.

.. attribute:: permission.microphone

Permission to access the microphone.

.. attribute:: permission.coarse_location

Permission to determine a rough GPS location.

.. attribute:: permission.fine_location

Permission to determine a precise GPS location.

.. attribute:: permission.background_location

Permission to track GPS location while in the background.

.. attribute:: permission.photo_library

Permission to access the user's photo library.

If a cross-platform permission is used, it will be mapped to platform-specific values in
whatever files are used to define permissions on that platform.

Permissions can also be configured by adding platform-specific configuration items. See the documentation for the platform backends to see the available options.

The value for each permission is a short description of why that permission is required.
If the platform requires, the value may be displayed to the user as part of an
authorization dialog. This description should describe *why* the app requires the
permission, rather than a generic description of the permission being requested.

The use of permissions may also imply other settings in your app. See the individual
platform backends for details on how cross-platform permissions are mapped.

.. _document-types:

Document types
==============

.. currentmodule:: document_type_id

Applications in a project can register themselves with the operating system as
handlers for specific document types by adding a ``document_type``
configuration section for each document type the application can support. This
section follows the format:

    ``[tool.briefcase.app.<app name>.document_type.<document type id>]``

or, for a platform-specific definition:

    ``[tool.briefcase.app.<app name>.<platform>.document_type.<document type id>]``

The ``document type id`` is an identifier, in alphanumeric format.

The document type declaration requires the following settings:

.. attribute:: description

A short, one-line description of the document format.

.. attribute:: extension

The file extension to register, without a leading dot.

.. attribute:: icon

A path, relative to the directory where the ``pyproject.toml`` file is located,
to an image for an icon to register for use with documents of this type. The
path should *exclude* the extension; Briefcase will append a platform-appropriate extension when configuring the application. For example, an icon
specification of::

    icon = "resources/icon"

will use ``resources/icon.icns`` on macOS, and ``resources/icon.ico`` on
Windows.

Some platforms also require different *variants* (e.g., both square and round
icons). These variants can be specified by qualifying the icon specification::

    icon.round = "resource/round-icon"
    icon.square = "resource/square-icon"

Some platforms require multiple icons, at different sizes; these will be
handled by appending the required size to the provided icon name. For example,
iOS requires multiple icon sizes (ranging from 20px to 1024px); Briefcase will
look for ``resources/icon-20.png``, ``resources/icon-1024.png``, and so on. The
sizes that are required are determined by the platform template.

If a platform requires both different sizes *and* variants, the variant
handling and size handling will be combined. For example, Android requires
round and square icons, in sizes ranging from 48px to 192px; Briefcase will
look for ``resource/round-icon-42.png``, ``resource/square-icon-42.png``,
``resource/round-icon-192.png``, and so on.

.. attribute:: mime_type

A MIME type for the document format. This is used to register the document type with the
operating system. For example, ``image/png`` for PNG image files, or ``application/pdf``
for PDF files. A list of common MIME types is found in `Mozilla's list
<https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types/Common_types>`__. A
full list is available at `IANA
<https://www.iana.org/assignments/media-types/media-types.xhtml>`__. Where platforms allow,
this MIME type will be used to determine other details about the document type.

If you do not specify a MIME type, Briefcase will generate a default MIME type of the
*unregistered* type ``application/x-<app name>-<document type id>``, e.g.
``application/x-myapp-data``. The ``x-`` prefix is specified by `RFC 2046
<https://www.rfc-editor.org/rfc/rfc2046.html>`__ for "private" MIME types. If you are
not using a formally registered mime type, you *must* use the ``x-`` prefix, or
`formally apply to IANA <https://www.iana.org/form/media-types>`__ for a new registered
MIME type.

.. attribute:: url

A URL for help related to the document format.

Platform support
----------------

Some platforms have specific configuration options that are only relevant to that
platform. In particular, Apple platforms (macOS, iOS) have a more elaborate system for
document types, and require additional configuration to use document types. If you want
to support document types on these platforms, you will need to read the macOS
:ref:`macOS-document-types` section for more information.

PEP621 compatibility
====================

Many of the keys that exist in Briefcase's configuration have analogous settings
in `PEP621 project metadata
<https://packaging.python.org/en/latest/specifications/pyproject-toml/>`__.
If your ``pyproject.toml`` defines a ``[project]`` section, Briefcase will honor
those settings as a top level definition. Any ``[tool.briefcase]`` definitions
will override those in the ``[project]`` section.

The following PEP621 project metadata keys will be used by Briefcase if they are
available:

* ``version`` maps to the same key in Briefcase.
* ``authors`` The ``email`` and ``name`` keys of the first value in the
  ``authors`` setting map to :attr:`author` and :attr:`author_email`.
* ``dependencies`` maps to the Briefcase :attr:`requires` setting. This is a
  cumulative setting; any packages defined in the :attr:`requires` setting at the
  ``[tool.briefcase]`` level will be appended to the packages defined with
  ``dependencies`` at the ``[project]`` level.
* ``description`` maps to the same key in Briefcase.
* ``test`` in an ``[project.optional-dependencies]`` section maps to
  :attr:`test_requires`., As with ``dependencies``/:attr:`requires`, this is a
  cumulative setting.
* ``text`` in a ``[project.license]`` section will be mapped to :attr:`license`.
* ``homepage`` in a ``[project.urls]`` section will be mapped to :attr:`url`.
* ``requires-python`` will be used to validate the running Python interpreter's
  version against the requirement.
