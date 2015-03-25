$ ->
  if $("#swagger-ui-container-v2").length > 0
    swaggerUi = new SwaggerUi
      url: "/api/v2/doc.json"
      dom_id: "swagger-ui-container-v2"
      supportedSubmitMethods: ['get', 'post', 'put', 'delete']
      onComplete: (swaggerApi, swaggerUi)->
        $('pre code').each (i, e)-> hljs.highlightBlock e
      onFailure: (data)->
      docExpansion: "list"
    swaggerUi.load()
    console.log("v2")
