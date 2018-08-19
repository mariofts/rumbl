
## Project generator
`mix phx.new rumbl --database mysql`

## Managing Users
`mix phx.gen.html Manage User users name:string username:string password:string password_hash:string --web Accounts`

## Video Library
`mix phx.gen.html Library Video videos user_id:references:users url:string title:string description:text --web Library`

## Adding video categories
`mix phx.gen.schema Library.Category categories name:string`
`mix ecto.gen.migration add_category_id_to_video`

