module oxdao::icon
{
    use sui::url::{Self, Url};

    public(package) fun get_icon_url(): Url {
        return url::new_unsafe_from_bytes(b"data:image/webp;base64,")
    }
}