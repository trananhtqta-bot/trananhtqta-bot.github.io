// Serves a static site exactly like GitHub Pages did (directory index, extensionless
// pages, 301 for missing trailing slash, shared 404 page). Static files are served by
// the assets layer for free; this code only runs when no file matches the URL.
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // www.thaibinh.shop -> thaibinh.shop (only the root Worker's routes include www)
    if (url.hostname.startsWith("www.")) {
      url.hostname = url.hostname.slice(4);
      url.protocol = "https:";
      return Response.redirect(url.toString(), 301);
    }

    const path = url.pathname;
    const asset = (p, init) => env.ASSETS.fetch(new Request(new URL(p, url), init ?? request));

    if (request.method === "GET" || request.method === "HEAD") {
      if (path.endsWith("/")) {
        const r = await asset(path + "index.html");
        if (r.status !== 404) return r;
      } else {
        const dir = await asset(path + "/index.html", { method: "HEAD" });
        if (dir.status === 200) {
          url.pathname = path + "/";
          return Response.redirect(url.toString(), 301);
        }
        const page = await asset(path + ".html");
        if (page.status !== 404) return page;
      }
    }

    const nf = await asset("/404.html", { method: "GET" });
    return new Response(request.method === "HEAD" ? null : nf.body, {
      status: 404,
      headers: nf.headers,
    });
  },
};
