<script>
const { name, size = 1.5, color = 'currentcolor' } = $props()
const url = `url("/icon/${name}.svg")`
</script>

<i
    style:width={size + 'rem'}
    style:height={size + 'rem'}
    style:background-color={color}
    style:mask={url + 'center / contain no-repeat'}
></i>

<style>
i {
    display: block;
}
</style>
