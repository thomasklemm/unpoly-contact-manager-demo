[![Unpoly](https://unpoly.com/images/unpoly_logo-31fe0b97.svg)](https://unpoly.com/)

[3.12](https://unpoly.com/version_choice)

[API](https://unpoly.com/api) [Tutorial](https://unpoly.com/tutorial) [Demo](https://demo.unpoly.com/) [Install](https://unpoly.com/install) [Changes](https://unpoly.com/changes) [Support](https://unpoly.com/support)[GitHub](https://github.com/unpoly/unpoly)[Menu](https://unpoly.com/menu/narrow)

# Installing Unpoly

## No dependencies

Unpoly has **no dependencies** on the client or server.

You can write your server-side code in **any programming language** like Ruby, Node.js, PHP or Python.
By loading the [frontend files](https://unpoly.com/install#files) below, Unpoly's API becomes available to your HTML templates and JavaScripts.

**No server-side integration is required**.


Unpoly also works great with static sites.


## [\#](https://unpoly.com/install\#files)Frontend files

Unpoly consists one JavaScript file and one CSS file:


| Development | Production |
| --- | --- |
| [`unpoly.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly.js) | [`unpoly.min.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly.min.js) | 57.1 KB gzipped |
| [`unpoly.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly.css) | [`unpoly.min.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly.min.css) | 1.0 KB gzipped |

`unpoly.js` is transpiled to ES2020 and will work in all modern browsers.

If Internet Explorer 11 or legacy Safari versions are a concern for you, see [legacy browser support](https://unpoly.com/install#legacy-browsers).


## [\#](https://unpoly.com/install\#initialization)Initialization

Include Unpoly before your own stylesheets and JavaScripts:


```html
<!DOCTYPE html>
<html>
  <head>
    <link rel="stylesheet" href="unpoly.css" />
    <link rel="stylesheet" href="script.css" />
    <script src="unpoly.js"></script>
    <script src="scripts.js"></script>
  </head>
  <body>
    <!-- HTML here may use Unpoly attributes like [up-follow] -->
  </body>
</html>
```

You may also load Unpoly with `<script defer>` or `<script type="module">`.


By default, Unpoly automatically initializes on the [`DOMContentLoaded`](https://developer.mozilla.org/en-US/docs/Web/API/Window/DOMContentLoaded_event)
event and runs your [compilers](https://unpoly.com/up.compiler) on the initial page.
For **manual** initialization, load Unpoly with [<script up-boot="manual">](https://unpoly.com/up-boot-manual) and later call [`up.boot()`](https://unpoly.com/up.boot).


`unpoly.js` defines a single global property `window.up` to expose its [API](https://unpoly.com/api) to your JavaScripts.


## [\#](https://unpoly.com/install\#methods)Installation methods

You have multiple options for downloading and integrating Unpoly:


- [Link to a CDN](https://unpoly.com/install/cdn) (great to test-drive)
- [Download](https://unpoly.com/install/download)
- [Install with npm](https://unpoly.com/install/npm)
- [Install with Ruby](https://unpoly.com/install/ruby)
- [Install with PHP](https://unpoly.com/install/php)
- [Install with Python](https://unpoly.com/install/python)
- [Install with Elixir](https://unpoly.com/install/elixir)

## [\#](https://unpoly.com/install\#legacy-browsers)Legacy browser support

Recent versions of Unpoly supports [all modern browsers](https://unpoly.com/up.framework.isSupported).

The last version with support for Internet Explorer 11 is [2.7](https://unpoly.com/changes/2.7.1).


`unpoly.js` also uses modern JavaScript syntax that may not supported by some legacy browsers or build pipelines.
If you're not already working around this with a transpiler like [Babel](https://babeljs.io/),
you may also use the ES6 build of Unpoly:


| Development | Production |
| --- | --- |
| [`unpoly.es6.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly.es6.js) | [`unpoly.es6.min.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly.es6.min.js) | 59.6 KB gzipped |

The ES6 build does not contain any polyfills.


## [\#](https://unpoly.com/install\#bootstrap)Bootstrap integration

If you're using [Bootstrap](https://getbootstrap.com/), there are some **optional** files that configures
Unpoly to use Bootstrap's CSS classes:


| Development | Production |
| --- | --- |
| [`unpoly-bootstrap3.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap3.js) | [`unpoly-bootstrap3.min.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap3.min.js) | 0.5 KB gzipped |
| [`unpoly-bootstrap3.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap3.css) | [`unpoly-bootstrap3.min.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap3.min.css) | 0.1 KB gzipped |
| [`unpoly-bootstrap4.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap4.js) | [`unpoly-bootstrap4.min.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap4.min.js) | 0.5 KB gzipped |
| [`unpoly-bootstrap4.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap4.css) | [`unpoly-bootstrap4.min.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap4.min.css) | 0.1 KB gzipped |
| [`unpoly-bootstrap5.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap5.js) | [`unpoly-bootstrap5.min.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap5.min.js) | 0.5 KB gzipped |
| [`unpoly-bootstrap5.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap5.css) | [`unpoly-bootstrap5.min.css`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-bootstrap5.min.css) | 0.1 KB gzipped |

## [\#](https://unpoly.com/install\#upgrading)Upgrade shim

If you're [upgrading from an older version](https://unpoly.com/changes/upgrading) you should also load `unpoly-migrate.js`
to polyfill deprecated APIs:


| Development | Production |
| --- | --- |
| [`unpoly-migrate.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-migrate.js) | [`unpoly-migrate.min.js`](https://cdn.jsdelivr.net/npm/unpoly@3.12.1/unpoly-migrate.min.js) | 9.0 KB gzipped |

Made by
[Henning Koch](https://twitter.com/triskweline)

[Imprint](https://unpoly.com/imprint)

[Privacy policy](https://unpoly.com/privacy)