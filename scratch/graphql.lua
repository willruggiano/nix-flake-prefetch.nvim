local query = [[
{
  repository(name: "%s", owner: "%s") {
    ref(qualifiedName: "master") {
      target {
        ... on Commit {
          id
          history(first: %d) {
            pageInfo {
              hasNextPage
            }
            edges {
              node {
                messageHeadline
                oid
              }
            }
          }
        }
      }
    }
  }
}
]]

local firvish = require "firvish"
local json = require "rapidjson"

firvish.start_job {
  command = "gh",
  args = {
    "api",
    "graphql",
    "-f",
    "query=" .. string.format(query, "firvish.nvim", "willruggiano", 5),
  },
  bopen = false,
  on_exit = function(self)
    vim.pretty_print(self:result())
  end,
}
