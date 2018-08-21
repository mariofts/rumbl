
## Project generator
`mix phx.new rumbl --database mysql`

## Managing Users
`mix phx.gen.html Manage User users name:string username:string password:string password_hash:string --web Accounts`

## Video Library
`mix phx.gen.html Library Video videos user_id:references:users url:string title:string description:text --web Library`

## Adding video categories
`mix phx.gen.schema Library.Category categories name:string`

## Annotations 
`mix phx.gen.schema Library.Annotation annotations body:text at:integer user_id:references:users video_id:references:videos`

